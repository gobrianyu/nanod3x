import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'collection.dart';
import 'models/dex_db.dart';

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  late final DexDB _dexDB;
  bool isLoading = true;

  @override
  void initState() {
    _loadDexDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CircularProgressIndicator()
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Collection(_dexDB.all),
      ),
    );
  }

  Future<void> _loadDexDB() async {
    const dataPath = 'assets/dex.json';
    final loadedDB = DexDB.initializeFromJson(await rootBundle.loadString(dataPath));
    setState(() {
      _dexDB = loadedDB;
      isLoading = false;
    });
  }
}
