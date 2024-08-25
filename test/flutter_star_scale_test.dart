// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_star_scale/flutter_star_scale.dart';
// import 'package:flutter_star_scale/flutter_star_scale_platform_interface.dart';
// import 'package:flutter_star_scale/flutter_star_scale_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterStarScalePlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterStarScalePlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterStarScalePlatform initialPlatform = FlutterStarScalePlatform.instance;

//   test('$MethodChannelFlutterStarScale is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterStarScale>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterStarScale flutterStarScalePlugin = FlutterStarScale();
//     MockFlutterStarScalePlatform fakePlatform = MockFlutterStarScalePlatform();
//     FlutterStarScalePlatform.instance = fakePlatform;

//     expect(await flutterStarScalePlugin.getPlatformVersion(), '42');
//   });
// }
