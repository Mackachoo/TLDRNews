import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tldrnews_app/src/app.dart';
import 'package:tldrnews_app/src/services/config_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional: prefer .env values when present locally. CI builds an empty .env
  // and supplies real values via --dart-define, which the code below falls back to.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env asset missing or unreadable — fall back to compile-time defines.
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ConfigService.initialize();

  runApp(App());
}
