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
    _stream = _streamController.stream.asyncExpand((params) {
      return _eventChannel.receiveBroadcastStream(params);
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

  void connect(ConnectionInfo info) {
    _streamController.add({...info.toMap(), "ACTION": "connect"});
  }

  void disconnect() {
    _streamController.add({"ACTION": "disconnect"});
  }

  void tare() {
    _streamController.add({"ACTION": "tare"});
  }

  void dispose() {
    _subscription?.cancel();
    _streamController.close();
  }
}
