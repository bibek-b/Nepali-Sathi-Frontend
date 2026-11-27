import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores accessibility preferences locally on the device.
/// These settings do not require a backend or database.
class AccessibilitySettingsController extends ChangeNotifier {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static const _largeTextKey = 'accessibility.largeText';
  static const _highContrastKey = 'accessibility.highContrast';
  static const _voiceStatusKey = 'accessibility.voiceStatus';

  // Accessibility-first defaults for the target user.
  bool _largeTextEnabled = true;
  bool _highContrastEnabled = true;
  bool _voiceStatusEnabled = false;

  bool get largeTextEnabled => _largeTextEnabled;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get voiceStatusEnabled => _voiceStatusEnabled;

  Future<void> load() async {
    try {
      _largeTextEnabled = await _preferences.getBool(_largeTextKey) ?? true;
      _highContrastEnabled =
          await _preferences.getBool(_highContrastKey) ?? true;
      _voiceStatusEnabled =
          await _preferences.getBool(_voiceStatusKey) ?? false;
    } catch (_) {
      // Keep accessible defaults if local preference loading fails.
    }

    notifyListeners();
  }

  Future<void> setLargeTextEnabled(bool value) async {
    if (_largeTextEnabled == value) return;

    _largeTextEnabled = value;
    notifyListeners();

    try {
      await _preferences.setBool(_largeTextKey, value);
    } catch (_) {
      // The setting still applies for the current app session.
    }
  }

  Future<void> setHighContrastEnabled(bool value) async {
    if (_highContrastEnabled == value) return;

    _highContrastEnabled = value;
    notifyListeners();

    try {
      await _preferences.setBool(_highContrastKey, value);
    } catch (_) {
      // The setting still applies for the current app session.
    }
  }

  Future<void> setVoiceStatusEnabled(bool value) async {
    if (_voiceStatusEnabled == value) return;

    _voiceStatusEnabled = value;
    notifyListeners();

    try {
      await _preferences.setBool(_voiceStatusKey, value);
    } catch (_) {
      // The setting still applies for the current app session.
    }
  }
}
