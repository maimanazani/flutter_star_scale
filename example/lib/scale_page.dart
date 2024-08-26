import 'package:flutter/material.dart';
import 'package:flutter_star_scale/flutter_star_scale.dart';

class ScalePage extends StatefulWidget {
  final ConnectionInfo connectionInfo;
  const ScalePage({super.key, required this.connectionInfo});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scale Example App'),
      ),
    );
  }
}
