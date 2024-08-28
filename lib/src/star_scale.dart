import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class StarScale {
  static const EventChannel _eventChannel =
      EventChannel('flutter_star_scale/events');
  static const MethodChannel _channel = MethodChannel('flutter_star_scale');

  final StreamController<dynamic> _streamController =
      StreamController<dynamic>.broadcast();

  Stream<dynamic> get scaleDataStream => _streamController.stream;

  void _startListeningToEventChannel(dynamic data) {
    _eventChannel.receiveBroadcastStream(data).listen((event) {
      _streamController.add(event);
    }, onError: (error) {
      _streamController.addError(error);
    });
  }

  void sink(dynamic data) {
    _startListeningToEventChannel(data);
  }

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
    sink({...info.toMap(), "ACTION": "connect"});
  }

  void tare() {
    sink({"ACTION": "tare"});
  }

  void disconnect() {
    sink({"ACTION": "disconnect"});
  }

  void dispose() {
    _streamController.close();
  }
}
