import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
    authDomain: "unicorn-hal.firebaseapp.com",
    projectId: "unicorn-hal",
    storageBucket: "unicorn-hal.firebasestorage.app",
    messagingSenderId: "384446500375",
    appId: "1:384446500375:web:096ccfe710c268ed1dd652",
  );
}
