import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return SettingsRepository.instance.get();
  }

  Future<void> update(AppSettings settings) async {
    await SettingsRepository.instance.save(settings);
    state = settings;
  }

  Future<void> setThemeMode(ThemeModeType mode) async {
    await update(state.copyWith(themeMode: mode));
  }

  Future<void> setFontSize(double size) async {
    await update(state.copyWith(fontSize: size));
  }

  Future<void> setUseDynamicColors(bool value) async {
    await update(state.copyWith(useDynamicColors: value));
  }

  ThemeMode get themeMode {
    switch (state.themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.amoled:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }

  bool get isAmoled => state.themeMode == ThemeModeType.amoled;
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
