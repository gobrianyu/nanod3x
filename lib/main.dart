import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokellection/collection.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBQT_xFSTrgADVpmrxAvunKFx_X-BHj7Ws',
      authDomain: 'nanod3x.firebaseapp.com',
      projectId: 'nanod3x',
      storageBucket: 'nanod3x.firebasestorage.app',
      messagingSenderId: '789914336089',
      appId: '1:789914336089:web:1d246db33cefe50e0caa48',
      measurementId: 'G-V635L0ZLLT',
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
