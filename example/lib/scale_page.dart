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
  final starScale = StarScale();
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
    starScale.scaleDataStream?.listen(
      (event) {
        print("Received data: $event");
        setState(() {
          data = ScaleData(event);
          print(data.toMap());
          if (data.status == ScaleStatus.connect_failed) {
            connectionText = "${data.msg}";
          }
          if (data.status == ScaleStatus.connect_success) {
            connectionText = "${data.msg}";
          }
        });
      },
      onError: (error) {
        print("Error: $error");
      },
      onDone: () {
        print("Stream closed");
      },
    );
    starScale.connect(widget.connectionInfo);
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
                onPressed: () {
                  if (data.status == ScaleStatus.connect_success) {
                    starScale.disconnect();
                  } else if (data.status == ScaleStatus.disconnect_success ||
                      data.status == ScaleStatus.connect_failed) {
                    starScale.connect(widget.connectionInfo);
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
              ),
            if (data.status == ScaleStatus.connect_success)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic, // Add this line
                    children: [
                      Text(
                        data.weightData?.weight?.toString() ?? "0.00",
                        style: const TextStyle(
                          fontSize: 50,
                        ),
                      ),
                      Text(
                        data.weightData?.unit ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Status: ${data.weightData?.status?.name}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Type: ${data.weightData?.type?.name}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            if (data.status == ScaleStatus.connect_success)
              TextButton(
                  onPressed: () {
                    starScale.tare();
                  },
                  child: Text("Tare"))
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
