import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Add this import for local development
import 'package:pokellection/collection.dart';

void main() async {
  // Load environment variables only for non-production (debug/profile) mode
  if (!kReleaseMode) {
    await dotenv.load(); // Load .env for local or development builds
    print('help: ${dotenv.env['FIREBASE_API_KEY']}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with environment variables or fallback to default for production
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: _getEnv('FIREBASE_API_KEY'),
      authDomain: _getEnv('FIREBASE_AUTH_DOMAIN'),
      projectId: _getEnv('FIREBASE_PROJECT_ID'),
      storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET'),
      messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID'),
      appId: _getEnv('FIREBASE_APP_ID'),
      measurementId: _getEnv('FIREBASE_MEASUREMENT_ID'),
    ),
  );

  runApp(const MainApp());
}

// Helper function to get the value from environment variables or fall back to defaults
String _getEnv(String key) {
  if (!kReleaseMode) {
    // Return from .env in non-production environments (like local or testing)
    return dotenv.env[key] ?? 'default-$key';
  } else {
    // Return the environment variable set by GitHub Actions in production
    return String.fromEnvironment(key, defaultValue: 'default-$key');
  }
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
