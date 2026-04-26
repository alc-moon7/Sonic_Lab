import Flutter
import AVFoundation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller = window?.rootViewController as! FlutterViewController
    let volumeChannel = FlutterMethodChannel(
      name: "com.soniclab/volume",
      binaryMessenger: controller.binaryMessenger
    )
    volumeChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "setMaxVolume":
        result(false)
      case "getVolume":
        result(AVAudioSession.sharedInstance().outputVolume)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
