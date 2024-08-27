import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class ScalePage extends StatefulWidget {
  final ConnectionInfo connectionInfo;
  const ScalePage({super.key, required this.connectionInfo});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  final plugin = StarScale();
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        plugin.scaleDataStream(widget.connectionInfo).listen((event) {
      print("Received data: $event");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scale Example App'),
      ),
      body: const Center(
        child: Text('Listening for scale data...'),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
