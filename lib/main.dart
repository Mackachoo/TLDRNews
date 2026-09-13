import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/services/config_service.dart';
import 'package:tldrnews_app/src/services/functions_service.dart';
import 'firebase_options.dart';

/// Set `USE_FIREBASE_EMULATOR=true` in `.env` to run against `firebase emulators:start`.
const useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
const emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST', defaultValue: '127.0.0.1');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useEmulator) connectEmulators();

  await ConfigService.initialize();

  runApp(App());
}

void connectEmulators() {
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  FirebaseFunctions.instanceFor(
    region: FunctionsService.region,
  ).useFunctionsEmulator(emulatorHost, 5001);
  debugPrint('main: using Firebase emulators on $emulatorHost');
}
