import 'package:flutter/services.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class StarScale {
  static const MethodChannel _channel = MethodChannel('flutter_star_scale');
  static const EventChannel _eventChannel =
      EventChannel('flutter_star_scale/events');

  Future<List<ConnectionInfo>> scanForScales(
      StarInterfaceType interfaceType) async {
    dynamic result =
        await _channel.invokeMethod('startScan', {'type': interfaceType.text});
    if (result is List) {
      return result.map<ConnectionInfo>((connectionInfo) {
        return ConnectionInfo(connectionInfo);
      }).toList();
    } else {
      return [];
    }
  }

  Future disconnect() async {
    await _channel.invokeMethod('disconnect');
  }

  Stream<dynamic> scaleDataStream(ConnectionInfo info) {
    return _eventChannel.receiveBroadcastStream(info.toMap());
  }
}
