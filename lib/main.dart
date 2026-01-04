import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'face_detection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Liveliness Detection Demo-1', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PermissionStatus? cameraPermissionStatus;

  /// Requests camera permission from the user.
  Future<void> requestCameraPermission(BuildContext context) async {
    cameraPermissionStatus = await Permission.camera.request();
    if (!(cameraPermissionStatus?.isGranted ?? false)) {
      // Handle permission denial
      // throw Exception('Camera permission denied');
      AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text("Camera access is required for verification."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Please Grand permission"),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text('Verify Your Identity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please click the button below to start verification',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            button(
              context: context,
              onPressed: () async {
                await requestCameraPermission(context).then((value) {
                  setState(() {});
                });
              },
              text: "Grand Permission",
            ),
            button(
              context: context,
              onPressed: !(cameraPermissionStatus?.isGranted ?? false)
                  ? null
                  : () async {
                      final cameras = await availableCameras();
                      if (cameras.isNotEmpty) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FaceDetectionPage(),
                          ),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification Successful!'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Camera not active!')),
                        );
                      }
                    },
              text: "Verify Now",
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton button({
    required BuildContext context,
    required String text,
    required Function()? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlueAccent,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class PermissionDeniedApp extends StatelessWidget {
  const PermissionDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Permission Denied")),
        body: Center(
          child: AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text("Camera access is required for verification."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Please Grand permission"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
