import 'dart:io';

final _traceFile = '/tmp/trace_${DateTime.now().millisecondsSinceEpoch}.txt';

void trace(String msg) {
  final ts = DateTime.now().toIso8601String();
  final line = '$ts [TRACE] $msg';
  print(line);
  try {
    File(_traceFile).writeAsStringSync('$line\n', mode: FileMode.append);
  } catch (_) {}
}
