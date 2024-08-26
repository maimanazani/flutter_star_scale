import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';
import 'package:flutter_star_scale_example/scale_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ConnectionInfo> scales = [];

  @override
  void initState() {
    super.initState();
    scanScales();
  }

  Future<void> scanScales() async {
    try {
      List<ConnectionInfo> results =
          await StarScale.scanForScales(StarInterfaceType.BluetoothLowEnergy);
      setState(() {
        scales = results;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void handleTap(BuildContext context, ConnectionInfo info) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScalePage(connectionInfo: info)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Scale Example App'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: scales.length,
              itemBuilder: (BuildContext context, int index) {
                ConnectionInfo scale = scales[index];
                return ListTile(
                  onTap: () => handleTap(context, scale),
                  title: Text(
                      "${scale.scaleTypeKey} - ${scale.interfaceTypeKey} - ${scale.deviceNameKey}"),
                  subtitle: Text("${scale.identifierKey}"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                );
              },
            ),
          )),
    );
  }
}
