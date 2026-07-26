import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/database_service.dart';

final String _tracePath = '/tmp/trace_${DateTime.now().millisecondsSinceEpoch}.txt';

void _trace(String msg) {
  final line = '${DateTime.now().toIso8601String()} $msg';
  print(line);
  try {
    File(_tracePath).writeAsStringSync('$line\n', mode: FileMode.append);
  } catch (_) {}
}

void main() {
  runZonedGuarded(() {
    _trace('1 main entered');

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
    runApp(
      ProviderScope(
        child: _AppRoot(),
      ),
    );
    _trace('5 runApp returned');
  }, (error, stack) {
    _trace('FATAL ZONED ERROR: $error');
    _trace('FATAL ZONED STACK: $stack');
  });
}

class _AppRoot extends StatefulWidget {
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _initializing = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _trace('6 _AppRoot initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trace('7 FIRST POST FRAME CALLBACK');
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    _trace('8 _initializeApp start');
    try {
      await DatabaseService.instance.initialize();
      _trace('9 database initialized ok=${DatabaseService.instance.isInitialized} err=${DatabaseService.instance.hasError}');
    } catch (e, stack) {
      _trace('9 database FAILED: $e');
      _trace('9 stack: $stack');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _initializing = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _initializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _trace('10 _AppRoot build init=$_initializing err=$_hasError');

    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (_initializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        home: const Scaffold(
          backgroundColor: Color(0xFF6C63FF),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _trace('11 showing real app');
    return const NotesApp();
  }
}
