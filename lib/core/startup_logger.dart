import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

class StartupLogger {
  static final StartupLogger _instance = StartupLogger._();
  static StartupLogger get instance => _instance;

  StartupLogger._();

  int _step = 0;
  late final String _logPath;
  IOSink? _fileSink;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = Directory.systemTemp;
      _logPath = '${dir.path}/startup_log_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(_logPath);
      _fileSink = file.openWrite(mode: FileMode.writeOnly);
      _initialized = true;
      _write('StartupLogger initialized. Log file: $_logPath');
    } catch (e) {
      _initialized = true;
      _write('StartupLogger file init failed: $e');
    }
  }

  void step(String message) {
    _step++;
    _write('[$_step] $message');
  }

  void error(String message, [Object? error, StackTrace? stack]) {
    _write('[ERROR] $message');
    if (error != null) _write('[ERROR] Exception: $error');
    if (stack != null) _write('[ERROR] Stack:\n$stack');
  }

  void _write(String msg) {
    final ts = DateTime.now().toIso8601String();
    final line = '$ts $msg';
    print(line);
    try {
      _fileSink?.writeln(line);
      _fileSink?.flush();
    } catch (_) {}
  }

  Future<void> flushAndClose() async {
    try {
      await _fileSink?.flush();
      await _fileSink?.close();
    } catch (_) {}
  }

  String get logPath => _logPath;
}
