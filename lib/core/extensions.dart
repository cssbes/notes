import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String get formatted {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    if (year == now.year) {
      return DateFormat('MMM d').format(this);
    }
    return DateFormat('MMM d, y').format(this);
  }

  String get fullDate => DateFormat('MMM d, yyyy').format(this);

  String get fullDateTime => DateFormat('MMM d, yyyy \'at\' h:mm a').format(this);
}

extension StringCapitalize on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isIOS => theme.platform == TargetPlatform.iOS;
}
