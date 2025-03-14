import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; // For loading the asset
import 'package:pokellection/collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the Firebase configuration from the config.json file
  final configString = await rootBundle.loadString('assets/config.json');
  final configMap = jsonDecode(configString);

  // Initialize Firebase with the loaded configuration
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: configMap['apiKey'],
      authDomain: configMap['authDomain'],
      projectId: configMap['projectId'],
      storageBucket: configMap['storageBucket'],
      messagingSenderId: configMap['messagingSenderId'],
      appId: configMap['appId'],
      measurementId: configMap['measurementId'],
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Collection(),
      ),
    );
  }
}
