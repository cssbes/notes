import 'dart:convert';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  Future<String> exportAsJson() async {
    final backup = DatabaseService.instance.exportBackup();
    final json = const JsonEncoder.withIndent('  ').convert(backup);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/notes_backup.json');
    await file.writeAsString(json);
    return file.path;
  }

  Future<String> exportAsMarkdown() async {
    final notes = DatabaseService.instance.getAllNotes();
    final buffer = StringBuffer();

    for (final note in notes) {
      buffer.writeln('# ${note.title}');
      buffer.writeln();
      if (note.contentDelta.isNotEmpty) {
        try {
          final deltaJson = jsonDecode(note.contentDelta);
          final document = Document.fromJson(deltaJson as List<dynamic>);
          buffer.writeln(document.toPlainText());
        } catch (_) {
          buffer.writeln(note.plainText);
        }
      } else {
        buffer.writeln(note.plainText);
      }
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/notes_export.md');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<void> shareFile(String path) async {
    final file = XFile(path);
    await Share.shareXFiles([file]);
  }

  Future<bool> importFromJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return false;

    final file = File(result.files.single.path!);
    final json = await file.readAsString();
    final data = jsonDecode(json) as Map<String, dynamic>;

    await DatabaseService.instance.importBackup(data);
    return true;
  }
}
