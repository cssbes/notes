import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AppInitializer extends StatefulWidget {
  final WidgetBuilder onInitialized;

  const AppInitializer({super.key, required this.onInitialized});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initializing = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    debugPrint('[AppInitializer] Starting initialization...');
    try {
      await DatabaseService.instance.initialize();
    } catch (e, stack) {
      debugPrint('[AppInitializer] Unhandled error during init: $e');
      debugPrint('[AppInitializer] Stack trace: $stack');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _initializing = false;
        });
      }
      return;
    }

    if (!mounted) return;

    if (DatabaseService.instance.hasError) {
      debugPrint(
          '[AppInitializer] Database init reported error: ${DatabaseService.instance.errorMessage}');
      setState(() {
        _hasError = true;
        _errorMessage = DatabaseService.instance.errorMessage;
        _initializing = false;
      });
      return;
    }

    debugPrint('[AppInitializer] Initialization successful.');
    if (mounted) {
      setState(() {
        _initializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        home: const _LoadingScreen(),
      );
    }

    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          brightness: Brightness.light,
        ),
        home: _ErrorScreen(errorMessage: _errorMessage, onRetry: _init),
      );
    }

    return widget.onInitialized(context);
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ErrorScreen({this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Startup Error',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
