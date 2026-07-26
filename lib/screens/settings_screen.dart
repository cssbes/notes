import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/theme/app_colors.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SizedBox(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFFE4E6EB)
                    : const Color(0xFF1C1E21),
              ),
            ),
          ),
          _SectionCard(
            isDark: isDark,
            title: 'Appearance',
            children: [
              SettingsTile(
                icon: Icons.brightness_6_rounded,
                title: 'Theme',
                subtitle: _themeLabel(settings.themeMode),
                onTap: () => _showThemePicker(context, ref),
                iconColor: AppColors.accent,
              ),
              const Divider(height: 1, indent: 66),
              SettingsTile(
                icon: Icons.text_fields_rounded,
                title: 'Font Size',
                subtitle: '${settings.fontSize.toInt()} pt',
                trailing: SizedBox(
                  width: 160,
                  child: Slider(
                    value: settings.fontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    divisions: 12,
                    activeColor: AppColors.accent,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .setFontSize(val);
                    },
                  ),
                ),
                iconColor: AppColors.tagPurple,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            isDark: isDark,
            title: 'Data',
            children: [
              SettingsTile(
                icon: Icons.upload_file_rounded,
                title: 'Export as JSON',
                subtitle: 'Backup all notes, folders, and tags',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                iconColor: AppColors.tagGreen,
              ),
              const Divider(height: 1, indent: 66),
              SettingsTile(
                icon: Icons.download_rounded,
                title: 'Import JSON',
                subtitle: 'Restore from a backup file',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                iconColor: AppColors.tagOrange,
              ),
              const Divider(height: 1, indent: 66),
              SettingsTile(
                icon: Icons.description_outlined,
                title: 'Export as Markdown',
                subtitle: 'Export all notes as markdown',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                iconColor: AppColors.tagTeal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            isDark: isDark,
            title: 'Storage',
            children: [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Notes v1.0.0',
                iconColor: AppColors.archived,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeModeType mode) {
    switch (mode) {
      case ThemeModeType.system:
        return 'System';
      case ThemeModeType.light:
        return 'Light';
      case ThemeModeType.dark:
        return 'Dark';
      case ThemeModeType.amoled:
        return 'AMOLED';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Choose Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              ...ThemeModeType.values.map((mode) {
                final selected =
                    ref.read(settingsProvider).themeMode == mode;
                return ListTile(
                  leading: Icon(
                    _themeIcon(mode),
                    color: selected ? AppColors.accent : null,
                  ),
                  title: Text(_themeLabel(mode)),
                  trailing: selected
                      ? const Icon(Icons.check_rounded, color: AppColors.accent)
                      : null,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeModeType mode) {
    switch (mode) {
      case ThemeModeType.system:
        return Icons.settings_brightness_rounded;
      case ThemeModeType.light:
        return Icons.light_mode_rounded;
      case ThemeModeType.dark:
        return Icons.dark_mode_rounded;
      case ThemeModeType.amoled:
        return Icons.nightlight_round;
    }
  }

}

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
