enum ThemeModeType { system, light, dark, amoled }

class AppSettings {
  final ThemeModeType themeMode;
  final double fontSize;
  final bool useDynamicColors;

  const AppSettings({
    this.themeMode = ThemeModeType.system,
    this.fontSize = 16,
    this.useDynamicColors = false,
  });

  factory AppSettings.defaults() {
    return const AppSettings();
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'fontSize': fontSize,
      'useDynamicColors': useDynamicColors,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: ThemeModeType.values[
          (map['themeMode'] as int?) ?? ThemeModeType.system.index],
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 16,
      useDynamicColors: (map['useDynamicColors'] as bool?) ?? false,
    );
  }

  AppSettings copyWith({
    ThemeModeType? themeMode,
    double? fontSize,
    bool? useDynamicColors,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
    );
  }
}
