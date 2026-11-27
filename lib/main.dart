import 'package:flutter/material.dart';

import 'package:nepal_sathi_frontend/features/speech_to_text/controllers/accessibility_settings_controller.dart';
import 'package:nepal_sathi_frontend/features/speech_to_text/screens/home_screen.dart';
import 'package:nepal_sathi_frontend/features/speech_to_text/screens/splash_screen.dart';
import 'package:nepal_sathi_frontend/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NepaliSathiApp());
}

class NepaliSathiApp extends StatefulWidget {
  const NepaliSathiApp({super.key});

  @override
  State<NepaliSathiApp> createState() => _NepaliSathiAppState();
}

class _NepaliSathiAppState extends State<NepaliSathiApp> {
  late final AccessibilitySettingsController _accessibilitySettings;

  late final Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();

    _accessibilitySettings = AccessibilitySettingsController();

    _startupFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Ensure the splash is visible for at least 1.5 seconds.
    final minimumSplashDuration = Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );

    try {
      await _accessibilitySettings.load();
    } catch (e) {
      debugPrint('Could not load accessibility settings: $e');
    }

    await minimumSplashDuration;
  }

  @override
  void dispose() {
    _accessibilitySettings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Sathi',

      theme: AppTheme.light,

      builder: (context, child) {
        return ListenableBuilder(
          listenable: _accessibilitySettings,
          builder: (context, _) {
            final theme = _accessibilitySettings.highContrastEnabled
                ? AppTheme.highContrast
                : AppTheme.light;

            final mediaQuery = MediaQuery.of(context);

            final systemScale = mediaQuery.textScaler.scale(1.0);

            final appScale = _accessibilitySettings.largeTextEnabled
                ? 1.25
                : 1.0;

            return Theme(
              data: theme,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(systemScale * appScale),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },

      home: FutureBuilder<void>(
        future: _startupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }

          return HomeScreen(accessibilitySettings: _accessibilitySettings);
        },
      ),
    );
  }
}
