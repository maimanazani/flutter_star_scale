import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class StarScale {
  static const MethodChannel _channel = MethodChannel('flutter_star_scale');
  static const EventChannel _eventChannel =
      EventChannel('flutter_star_scale/events');

  StreamSubscription<dynamic>? _subscription;
  final StreamController<dynamic> _streamController =
      StreamController.broadcast();
  Stream<dynamic>? _stream;

  StarScale() {
    _stream = _streamController.stream.asyncMap((params) {
      return _eventChannel.receiveBroadcastStream(params).first;
    });
  }

  Stream<dynamic>? get scaleDataStream => _stream;

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

  Future<void> connect(ConnectionInfo info) async {
    _streamController.add({...info.toMap(), "ACTION": "connect"});
  }

  Future<void> disconnect() async {
    _streamController.add({"ACTION": "disconnect"});
  }

  void dispose() {
    _subscription?.cancel();
    _streamController.close();
  }
}
