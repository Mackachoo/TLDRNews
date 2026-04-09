import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tldrnews_app/src/app.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(TLDRNewsApp());
}
