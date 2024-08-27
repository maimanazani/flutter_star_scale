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
  String connectionText = "";
  ScaleData data = ScaleData({});

  @override
  void initState() {
    readScale();
    super.initState();
  }

  void readScale() {
    setState(() {
      connectionText = "Connecting to scale...";
    });
    _subscription =
        plugin.scaleDataStream(widget.connectionInfo).listen((event) {
      print("Received data: $event");
      setState(() {
        data = ScaleData(event);
        if (data.status == ScaleStatus.connect_failed) {
          connectionText = "${data.msg}";
          _subscription?.cancel();
        }
        if (data.status == ScaleStatus.connect_success) {
          connectionText = "${data.msg}";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scale Example App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              connectionText,
              style: TextStyle(
                fontSize: 18,
                color: data.status == ScaleStatus.connect_success
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            if (data.status == ScaleStatus.connect_success ||
                data.status == ScaleStatus.connect_failed ||
                data.status == ScaleStatus.disconnect_success ||
                data.status == ScaleStatus.disconnect_failed)
              TextButton(
                onPressed: () async {
                  if (data.status == ScaleStatus.connect_success) {
                    await plugin.disconnect();
                  } else if (data.status == ScaleStatus.disconnect_success ||
                      data.status == ScaleStatus.connect_failed) {
                    readScale();
                  }
                },
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side:
                          const BorderSide(color: Colors.black), // Border color
                    ),
                  ),
                ),
                child: Text(
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    data.status == ScaleStatus.connect_success
                        ? "Disconnect"
                        : "Connect"),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
