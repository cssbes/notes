import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'widgets/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[main] App started.');

  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
    ));
    debugPrint('[main] System chrome configured.');
  } catch (e) {
    debugPrint('[main] Failed to set system chrome: $e');
  }

  runApp(
    ProviderScope(
      child: AppInitializer(
        onInitialized: (_) => const NotesApp(),
      ),
    ),
  );
}
