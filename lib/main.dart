import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final String _tracePath = '/tmp/trace_${DateTime.now().millisecondsSinceEpoch}.txt';
final List<String> _onScreenLog = [];

void _trace(String msg) {
  final ts = DateTime.now().toIso8601String();
  final line = '$ts $msg';
  print(line);
  _onScreenLog.add(line);
  if (_onScreenLog.length > 100) _onScreenLog.removeAt(0);
  try {
    File(_tracePath).writeAsStringSync('$line\n', mode: FileMode.append);
  } catch (_) {}
}

void main() {
  runZonedGuarded(() {
    _trace('1 main entered');
    _startApp();
    _trace('5 runApp returned');
  }, (error, stack) {
    _trace('FATAL ZONED ERROR: $error');
    _trace('FATAL ZONED STACK: $stack');
  });
}

void _startApp() {
  WidgetsFlutterBinding.ensureInitialized();
  _trace('2 binding initialized');

  FlutterError.onError = (details) {
    _trace('FLUTTER ERROR: ${details.exception}');
  };

  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
    ));
    _trace('3 system chrome done');
  } catch (e) {
    _trace('3 chrome FAILED: $e');
  }

  _trace('4 calling runApp');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _trace('6 MyApp initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trace('7 FIRST POST FRAME CALLBACK');
    });
  }

  @override
  Widget build(BuildContext context) {
    _trace('8 MyApp build');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.light,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF4CAF50),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'APP IS RUNNING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you see this, runApp() works',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GREEN BACKGROUND = FIRST FRAME RENDERED',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Startup Trace:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._onScreenLog.map((line) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              line,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
