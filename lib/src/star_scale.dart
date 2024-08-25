import 'package:flutter/services.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class StarScale {
  static const MethodChannel _channel = MethodChannel('flutter_star_scale');

  static Future<dynamic> scanForScales(StarInterfaceType interfaceType) async {
    dynamic result =
        await _channel.invokeMethod('startScan', {'type': interfaceType.text});
    return result;
  }
}
