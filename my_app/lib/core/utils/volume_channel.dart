import 'package:flutter/services.dart';

class VolumeChannel {
  static const MethodChannel _channel = MethodChannel('com.soniclab/volume');

  Future<bool> setMaxVolume() async {
    try {
      return await _channel.invokeMethod<bool>('setMaxVolume') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<double?> getVolume() async {
    try {
      return await _channel.invokeMethod<double>('getVolume');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
