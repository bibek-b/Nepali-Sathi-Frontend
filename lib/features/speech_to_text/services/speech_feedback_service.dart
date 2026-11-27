import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

/// Uses the device's built-in text-to-speech engine.
/// No audio is sent to an external service.
class SpeechFeedbackService {
  final FlutterTts _tts = FlutterTts();

  bool _checkedLanguage = false;
  bool _isNepaliAvailable = false;
  bool _isDisposed = false;

  Future<bool> _prepareNepaliVoice() async {
    if (_checkedLanguage) return _isNepaliAvailable;

    _checkedLanguage = true;

    try {
      if (Platform.isIOS) {
        await _tts.setSharedInstance(true);
      }

      final dynamic availableLanguages = await _tts.getLanguages;
      if (availableLanguages is! List) return false;

      String? nepaliLocale;

      // Prefer Nepal's locale. Accept another Nepali locale only if the
      // platform explicitly reports it as installed/available.
      for (final language in availableLanguages) {
        if (language is! String) continue;

        final normalized = language.replaceAll('_', '-').toLowerCase();
        if (normalized == 'ne-np') {
          nepaliLocale = language;
          break;
        }

        if (nepaliLocale == null && normalized.startsWith('ne-')) {
          nepaliLocale = language;
        }
      }

      if (nepaliLocale == null) return false;

      await _tts.setLanguage(nepaliLocale);
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);

      _isNepaliAvailable = true;
      return true;
    } catch (_) {
      _isNepaliAvailable = false;
      return false;
    }
  }

  Future<bool> speakNepali(String text) async {
    if (_isDisposed || text.trim().isEmpty) return false;

    final isAvailable = await _prepareNepaliVoice();
    if (!isAvailable || _isDisposed) return false;

    try {
      await _tts.stop();
      final result = await _tts.speak(text);
      return result == 1;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore platform stop failures.
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await stop();
  }
}
