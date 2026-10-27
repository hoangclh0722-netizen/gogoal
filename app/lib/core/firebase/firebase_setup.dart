import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

const _env = String.fromEnvironment('ENV', defaultValue: 'dev');
const _emulatorHost = String.fromEnvironment('EMULATOR_HOST', defaultValue: '127.0.0.1');

// Dev chạy trên app Firebase riêng trỏ vào project giả của Emulator,
// để không đụng app mặc định mà Android tự khởi tạo từ google-services.json
const _demoOptions = FirebaseOptions(
  apiKey: 'demo-key',
  appId: '1:000000000000:android:0000000000000000',
  messagingSenderId: '000000000000',
  projectId: 'demo-gogoal',
);

late final FirebaseFirestore appFirestore;
late final FirebaseAuth appAuth;

Future<void> initFirebase() async {
  if (_env == 'prod') {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    appFirestore = FirebaseFirestore.instance;
    appAuth = FirebaseAuth.instance;
    return;
  }
  final app = await Firebase.initializeApp(name: 'dev', options: _demoOptions);
  appFirestore = FirebaseFirestore.instanceFor(app: app)
    ..useFirestoreEmulator(_emulatorHost, 8080, automaticHostMapping: false);
  appAuth = FirebaseAuth.instanceFor(app: app);
  await appAuth.useAuthEmulator(_emulatorHost, 9099, automaticHostMapping: false);
}
