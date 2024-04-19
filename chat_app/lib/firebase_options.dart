import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjK0Eu0CMXHnnly7BeDqvFXOwRie4EEaE',
    appId: '1:360658613358:android:2e28e521ca8a08de71227f',
    messagingSenderId: '360658613358',
    projectId: 'chat-box-cft',
    storageBucket: 'chat-box-cft.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjK0Eu0CMXHnnly7BeDqvFXOwRie4EEaE',
    appId: '1:360658613358:ios:2e28e521ca8a08de71227f',
    messagingSenderId: '360658613358',
    projectId: 'chat-box-cft',
    storageBucket: 'chat-box-cft.appspot.com',
  );

}