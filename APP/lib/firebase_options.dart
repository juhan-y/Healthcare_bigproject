import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


// firebase 옵션 설정, app, api key, 프로젝트 설정 등
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAaoHt3t1BNJYToyoDTEFzbv9WuB6ch8T0',
    appId: '1:530716333525:web:31ab3b3fc300e57c35195c',
    messagingSenderId: '530716333525',
    projectId: 'healthcare-bigproject-27bbf',
    authDomain: 'healthcare-bigproject-27bbf.firebaseapp.com',
    storageBucket: 'healthcare-bigproject-27bbf.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxqKmElLgPgHQSFH69ELiyg9KECfGs0gA',
    appId: '1:530716333525:android:87de3936871bd2b935195c',
    messagingSenderId: '530716333525',
    projectId: 'healthcare-bigproject-27bbf',
    storageBucket: 'healthcare-bigproject-27bbf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtHDkpT4ilt3aqswfjQGuMBWYi-SuXkz8',
    appId: '1:530716333525:ios:1896c11bca4418ff35195c',
    messagingSenderId: '530716333525',
    projectId: 'healthcare-bigproject-27bbf',
    storageBucket: 'healthcare-bigproject-27bbf.appspot.com',
    iosClientId: '530716333525-runfimqv1dk9o8qqjqfd4q1v0coe8sf1.apps.googleusercontent.com',
    iosBundleId: 'com.example.healthcareBigproject',
  );
}
