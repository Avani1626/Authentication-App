// firebase config (from the web app registration)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyCnhlb38miDKPkYV-NEvaa2HZgqYDpL10U',
    appId: '1:490003987964:web:67ae162471df7505c10679',
    messagingSenderId: '490003987964',
    projectId: 'test-project-3ea7d',
    authDomain: 'test-project-3ea7d.firebaseapp.com',
    storageBucket: 'test-project-3ea7d.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyCnhlb38miDKPkYV-NEvaa2HZgqYDpL10U',
    appId: '1:490003987964:web:67ae162471df7505c10679',
    messagingSenderId: '490003987964',
    projectId: 'test-project-3ea7d',
    storageBucket: 'test-project-3ea7d.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyCnhlb38miDKPkYV-NEvaa2HZgqYDpL10U',
    appId: '1:490003987964:web:67ae162471df7505c10679',
    messagingSenderId: '490003987964',
    projectId: 'test-project-3ea7d',
    storageBucket: 'test-project-3ea7d.firebasestorage.app',
    iosBundleId: 'com.example.calcApp',
  );
}
