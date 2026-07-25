import '../models/app_settings.dart';
import '../services/database_service.dart';

class SettingsRepository {
  static final SettingsRepository instance = SettingsRepository._();
  SettingsRepository._();

  final _db = DatabaseService.instance;

  AppSettings get() => _db.getSettings();

  Future<void> save(AppSettings settings) async {
    await _db.saveSettings(settings);
  }
}
