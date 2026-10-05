import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_theme.dart';
import 'package:learning_plateform/firebase_options.dart';
import 'package:learning_plateform/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase exactly once.
  // Auto-initialization is disabled via AndroidManifest.xml meta-data
  // (firebase_auto_init_enabled = false) to prevent the native google-services
  // plugin from calling FirebaseApp.initializeApp() before Flutter starts,
  // which would cause [core/duplicate-app] "[DEFAULT]" already exists.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ProviderScope must wrap the entire widget tree for Riverpod to work.
  runApp(const ProviderScope(child: LMSArenaApp()));
}

class LMSArenaApp extends StatelessWidget {
  const LMSArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'LMS Arena',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.dark,
      // SplashScreen runs its 3-second animation then pushes AuthGate,
      // which listens to Firebase authStateChanges via Riverpod and routes
      // to MainShell (authenticated) or LoginScreen (not authenticated).
      home: const SplashScreen(),
    );
  }
}
