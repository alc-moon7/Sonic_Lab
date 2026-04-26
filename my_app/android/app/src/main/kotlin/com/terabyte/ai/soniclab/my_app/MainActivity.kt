package com.terabyte.ai.soniclab.my_app

import android.content.Context
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.PI
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sin
import kotlin.random.Random

class MainActivity : FlutterActivity() {
    private val tonePlayer = TonePlayer()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureVolumeChannel(flutterEngine)
        configureAudioChannel(flutterEngine)
    }

    override fun onDestroy() {
        tonePlayer.stop()
        super.onDestroy()
    }

    private fun configureVolumeChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.soniclab/volume"
        ).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "setMaxVolume" -> {
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
                    result.success(true)
                }
                "getVolume" -> {
                    val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    result.success(current.toDouble() / maxVolume.toDouble())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun configureAudioChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.soniclab/audio"
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "playSine" -> {
                        tonePlayer.playSine(
                            frequency = call.doubleArg("frequency"),
                            amplitude = call.doubleArg("amplitude"),
                            durationMs = call.intArg("durationMs"),
                            loop = call.boolArg("loop"),
                        )
                        result.success(null)
                    }
                    "playSweep" -> {
                        tonePlayer.playSweep(
                            startHz = call.doubleArg("startHz"),
                            endHz = call.doubleArg("endHz"),
                            durationMs = call.intArg("durationMs"),
                            type = call.stringArg("type"),
                            amplitude = call.doubleArg("amplitude"),
                        )
                        result.success(null)
                    }
                    "playPulse" -> {
                        tonePlayer.playPulse(
                            frequency = call.doubleArg("frequency"),
                            onMs = call.intArg("onMs"),
                            offMs = call.intArg("offMs"),
                            totalDurationMs = call.intArg("totalDurationMs"),
                            amplitude = call.doubleArg("amplitude"),
                        )
                        result.success(null)
                    }
                    "stop" -> {
                        tonePlayer.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("AUDIO_ENGINE_ERROR", error.message, null)
            }
        }
    }
}

private class TonePlayer {
    companion object {
        private const val SAMPLE_RATE = 44100
        private const val BUFFER_SAMPLES = 1024
        private const val TWO_PI = 2.0 * PI
    }

    @Volatile
    private var playbackToken = 0
    private var playbackThread: Thread? = null

    @Synchronized
    fun playSine(
        frequency: Double,
        amplitude: Double,
        durationMs: Int,
        loop: Boolean,
    ) {
        val safeFrequency = frequency.coerceIn(20.0, 20000.0)
        val safeAmplitude = amplitude.coerceIn(0.0, 1.0)
        val maxSamples = if (loop) Long.MAX_VALUE else samplesFor(durationMs)
        start(maxSamples) { frameIndex ->
            ToneFrame(
                frequency = safeFrequency,
                amplitude = safeAmplitude,
                active = frameIndex < maxSamples,
            )
        }
    }

    @Synchronized
    fun playSweep(
        startHz: Double,
        endHz: Double,
        durationMs: Int,
        type: String,
        amplitude: Double,
    ) {
        val safeStart = startHz.coerceIn(20.0, 20000.0)
        val safeEnd = endHz.coerceIn(20.0, 20000.0)
        val safeAmplitude = amplitude.coerceIn(0.0, 1.0)
        val maxSamples = samplesFor(durationMs)
        val random = Random(37)
        start(maxSamples) { frameIndex ->
            val progress = (frameIndex.toDouble() / maxSamples.toDouble()).coerceIn(0.0, 1.0)
            val frequency = when (type) {
                "logarithmic" -> safeStart * (safeEnd / safeStart).pow(progress)
                "sawtooth" -> safeStart + ((safeEnd - safeStart) * ((progress * 6.0) % 1.0))
                "random" -> safeStart + ((safeEnd - safeStart) * random.nextDouble())
                else -> safeStart + ((safeEnd - safeStart) * progress)
            }
            val envelope = if (type == "sawtooth") {
                0.35 + (0.65 * ((progress * 12.0) % 1.0))
            } else {
                1.0
            }
            ToneFrame(
                frequency = frequency,
                amplitude = safeAmplitude * envelope,
                active = frameIndex < maxSamples,
            )
        }
    }

    @Synchronized
    fun playPulse(
        frequency: Double,
        onMs: Int,
        offMs: Int,
        totalDurationMs: Int,
        amplitude: Double,
    ) {
        val safeFrequency = frequency.coerceIn(20.0, 20000.0)
        val safeAmplitude = amplitude.coerceIn(0.0, 1.0)
        val cycleMs = max(1, onMs + offMs)
        val maxSamples = samplesFor(totalDurationMs)
        start(maxSamples) { frameIndex ->
            val elapsedMs = (frameIndex.toDouble() / SAMPLE_RATE.toDouble()) * 1000.0
            ToneFrame(
                frequency = safeFrequency,
                amplitude = if ((elapsedMs % cycleMs.toDouble()) < onMs) safeAmplitude else 0.0,
                active = frameIndex < maxSamples,
            )
        }
    }

    @Synchronized
    fun stop() {
        playbackToken += 1
        playbackThread?.join(150)
        playbackThread = null
    }

    private fun start(maxSamples: Long, frameProvider: (Long) -> ToneFrame) {
        stop()
        val token = ++playbackToken
        playbackThread = Thread {
            Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
            val minBuffer = AudioTrack.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
            )
            val audioTrack = AudioTrack(
                AudioManager.STREAM_MUSIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                max(minBuffer, BUFFER_SAMPLES * 2),
                AudioTrack.MODE_STREAM,
            )
            val buffer = ShortArray(BUFFER_SAMPLES)
            var frameIndex = 0L
            var phase = 0.0
            try {
                audioTrack.play()
                while (token == playbackToken && frameIndex < maxSamples) {
                    var writeCount = 0
                    while (
                        writeCount < BUFFER_SAMPLES &&
                        token == playbackToken &&
                        frameIndex < maxSamples
                    ) {
                        val frame = frameProvider(frameIndex)
                        if (!frame.active) {
                            frameIndex = maxSamples
                            break
                        }
                        val sample = (sin(phase) * frame.amplitude * Short.MAX_VALUE)
                            .toInt()
                            .coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
                        buffer[writeCount] = sample.toShort()
                        phase += (TWO_PI * frame.frequency) / SAMPLE_RATE.toDouble()
                        if (phase > TWO_PI) {
                            phase %= TWO_PI
                        }
                        writeCount += 1
                        frameIndex += 1
                    }
                    if (writeCount > 0) {
                        audioTrack.write(buffer, 0, writeCount)
                    }
                }
            } finally {
                audioTrack.stop()
                audioTrack.release()
            }
        }.apply {
            name = "SonicLabTonePlayer"
            isDaemon = true
            start()
        }
    }

    private fun samplesFor(durationMs: Int): Long {
        val safeDuration = durationMs.coerceAtLeast(1)
        return (SAMPLE_RATE.toLong() * safeDuration.toLong()) / 1000L
    }
}

private data class ToneFrame(
    val frequency: Double,
    val amplitude: Double,
    val active: Boolean,
)

private fun MethodCall.argsMap(): Map<*, *> {
    return arguments as? Map<*, *> ?: emptyMap<Any, Any>()
}

private fun MethodCall.doubleArg(name: String): Double {
    return (argsMap()[name] as? Number)?.toDouble()
        ?: throw IllegalArgumentException("Missing numeric argument: $name")
}

private fun MethodCall.intArg(name: String): Int {
    return (argsMap()[name] as? Number)?.toInt()
        ?: throw IllegalArgumentException("Missing integer argument: $name")
}

private fun MethodCall.boolArg(name: String): Boolean {
    return argsMap()[name] as? Boolean
        ?: throw IllegalArgumentException("Missing boolean argument: $name")
}

private fun MethodCall.stringArg(name: String): String {
    return argsMap()[name] as? String
        ?: throw IllegalArgumentException("Missing string argument: $name")
}
