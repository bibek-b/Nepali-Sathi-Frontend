import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../services/audio_recording_services.dart';
import '../services/speech_feedback_service.dart';
import '../services/transcription_service.dart';

/// Owns screen state and user workflows. Widgets only render this state
/// and call the controller's public methods.
class SpeechToTextController extends ChangeNotifier {
  SpeechToTextController({
    AudioRecordingService? audioService,
    TranscriptionService? transcriptionService,
    SpeechFeedbackService? speechFeedbackService,
  }) : _audioService = audioService ?? AudioRecordingService(),
       _transcriptionService = transcriptionService ?? TranscriptionService(),
       _speechFeedbackService =
           speechFeedbackService ?? SpeechFeedbackService();

  final AudioRecordingService _audioService;
  final TranscriptionService _transcriptionService;
  final SpeechFeedbackService _speechFeedbackService;

  Timer? _recordingTimer;
  bool _disposed = false;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _voiceFeedbackEnabled = false;
  int _recordingSeconds = 0;
  int _speechOperationId = 0;

  String? _audioPath;
  String? _rawText;
  String? _correctedText;
  String? _errorMessage;

  // Read-only state exposed to widgets.
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  bool get hasRecording => _audioPath != null;
  bool get hasResult => _correctedText != null;
  bool get canRetryCorrection => _rawText != null && _correctedText == null;

  String? get errorMessage => _errorMessage;
  String? get correctedText => _correctedText;
  AudioPlayer get audioPlayer => _audioService.player;

  String get formattedDuration {
    final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Accessibility and voice feedback
  // ---------------------------------------------------------------------------

  void setVoiceFeedbackEnabled(bool enabled) {
    if (_voiceFeedbackEnabled == enabled) return;

    _voiceFeedbackEnabled = enabled;
    if (!enabled) {
      unawaited(_speechFeedbackService.stop());
    }
  }

  /// Announces short status messages only when the user enables voice feedback.
  /// We deliberately do not speak after recording starts: the phone's voice
  /// could be captured by the microphone.
  void _announceStatus(String message) {
    if (!_voiceFeedbackEnabled || _disposed) return;

    unawaited(
      _speechFeedbackService
          .speakNepali(message)
          .then((_) {})
          .catchError((Object _) {}),
    );
  }

  Future<void> toggleSpeakCorrectedText() async {
    // User wants to stop the current speech.
    if (_isSpeaking) {
      // Invalidate the previous speech request.
      _speechOperationId++;

      _isSpeaking = false;
      _notify();

      await _speechFeedbackService.stop();
      return;
    }

    final text = _correctedText;

    if (text == null || text.isEmpty || _isProcessing) return;

    // Create a unique ID for this speech operation.
    final operationId = ++_speechOperationId;

    _isSpeaking = true;
    _errorMessage = null;
    _notify();

    try {
      final spoken = await _speechFeedbackService.speakNepali(text);

      // Ignore results from intentionally stopped or outdated requests.
      if (_disposed || operationId != _speechOperationId) return;

      if (!spoken) {
        _errorMessage =
            'यस फोनमा नेपाली आवाज उपलब्ध छैन। फोनको Text-to-Speech सेटिङ जाँच गर्नुहोस्।';
      }
    } catch (_) {
      if (!_disposed && operationId == _speechOperationId) {
        _errorMessage = 'लेखाइ पढेर सुनाउन सकिएन।';
      }
    } finally {
      // Only the active operation can update the speaking state.
      if (!_disposed && operationId == _speechOperationId) {
        _isSpeaking = false;
        _notify();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Recording
  // ---------------------------------------------------------------------------

  Future<void> handleRecordingButtonTap() async {
    if (_isProcessing) return;

    if (_isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_isRecording || _isProcessing) return;

    _errorMessage = null;
    _notify();

    try {
      // Stop any spoken status/result before opening the microphone.
      await _speechFeedbackService.stop();
      _isSpeaking = false;

      final previousPath = _audioPath;
      final hasPermission = await _audioService.startRecording();

      if (_disposed) {
        if (hasPermission) await _audioService.stopRecording();
        return;
      }

      if (!hasPermission) {
        _errorMessage = 'माइक्रोफोन प्रयोग गर्न अनुमति दिनुहोस्।';
        _notify();
        return;
      }

      if (previousPath != null) {
        try {
          await _deleteFile(previousPath);
        } catch (_) {
          // A stale temporary file must not prevent a new recording.
        }
      }

      _audioPath = null;
      _rawText = null;
      _correctedText = null;
      _errorMessage = null;
      _recordingSeconds = 0;
      _isRecording = true;
      _startTimer();
      _notify();
    } catch (_) {
      _isRecording = false;
      _stopTimer();
      _errorMessage = 'रेकर्डिङ सुरु गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      _announceStatus(_errorMessage!);
      _notify();
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _stopTimer();

    try {
      final path = await _audioService.stopRecording();
      if (_disposed) return;

      _isRecording = false;
      if (path == null) {
        _errorMessage = 'रेकर्डिङ सुरक्षित गर्न सकिएन।';
        _announceStatus(_errorMessage!);
      } else {
        _audioPath = path;
        _errorMessage = null;
        _announceStatus('रेकर्डिङ रोकियो। अब सुन्नुहोस् वा पठाउनुहोस्।');
      }
      _notify();
    } catch (_) {
      _isRecording = false;
      _errorMessage = 'रेकर्डिङ रोक्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      _announceStatus(_errorMessage!);
      _notify();
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || !_isRecording) return;
      _recordingSeconds++;
      _notify();
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Playback and recording file management
  // ---------------------------------------------------------------------------

  Future<void> togglePlayback() async {
    final path = _audioPath;
    if (path == null) return;

    try {
      await _audioService.togglePlayback(path);
    } catch (_) {
      _errorMessage = 'रेकर्डिङ प्ले गर्न सकिएन।';
      _notify();
    }
  }

  Future<void> deleteRecording() async {
    final path = _audioPath;

    try {
      await _audioService.stopPlayback();
      await _speechFeedbackService.stop();
      if (path != null) await _deleteFile(path);

      _clearCurrentSession();
      _notify();
    } catch (_) {
      _errorMessage = 'रेकर्डिङ हटाउन सकिएन।';
      _notify();
    }
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ---------------------------------------------------------------------------
  // Transcription and correction
  // ---------------------------------------------------------------------------

  Future<void> submitRecording() async {
    final path = _audioPath;
    if (path == null || _isProcessing || _isRecording) return;

    _isProcessing = true;
    _errorMessage = null;
    _rawText = null;
    _correctedText = null;
    _announceStatus('तपाईंको बोलीलाई लेखाइमा परिवर्तन गर्दैछौँ।');
    _notify();

    try {
      final result = await _transcriptionService.transcribeAudio(path);
      if (_disposed) return;

      _rawText = result.rawText;
      _correctedText = result.correctedText;

      if (_correctedText == null) {
        _errorMessage =
            'तपाईंको लेखाइ सुधार गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
        _announceStatus(_errorMessage!);
      } else {
        _announceStatus(
          'तपाईंको लेखाइ तयार भयो। अब सुन्न वा कपी गर्न सक्नुहुन्छ।',
        );
      }
    } on ApiException catch (error) {
      if (_disposed) return;
      _errorMessage = _friendlyError(error);
      _announceStatus(_errorMessage!);
    } catch (_) {
      if (_disposed) return;
      _errorMessage = 'केही समस्या आयो। कृपया फेरि प्रयास गर्नुहोस्।';
      _announceStatus(_errorMessage!);
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  Future<void> retryCorrection() async {
    final rawText = _rawText;
    if (rawText == null || _isProcessing) return;

    _isProcessing = true;
    _errorMessage = null;
    _announceStatus('लेखाइ फेरि सुधार गर्दैछौँ।');
    _notify();

    try {
      _correctedText = await _transcriptionService.retryCorrection(rawText);
      _errorMessage = null;
      _announceStatus('तपाईंको लेखाइ तयार भयो।');
    } on ApiException catch (error) {
      if (_disposed) return;
      _errorMessage = _friendlyError(error);
      _announceStatus(_errorMessage!);
    } catch (_) {
      if (_disposed) return;
      _errorMessage = 'लेखाइ सुधार गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      _announceStatus(_errorMessage!);
    } finally {
      _isProcessing = false;
      _notify();
    }
  }

  Future<void> retry() async {
    if (canRetryCorrection) {
      await retryCorrection();
    } else if (hasRecording) {
      await submitRecording();
    } else {
      await startRecording();
    }
  }

  String _friendlyError(ApiException error) {
    switch (error.code) {
      case 'TRANSCRIPTION_FAILED':
        return 'आवाज बुझ्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      case 'CORRECTION_FAILED':
        return 'लेखाइ सुधार गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      case 'NETWORK_ERROR':
        return 'इन्टरनेट जडान जाँच गर्नुहोस्।';
      case 'INVALID_AUDIO_FORMAT':
        return 'यो अडियो फाइल प्रयोग गर्न मिल्दैन।';
      default:
        return error.message;
    }
  }

  // ---------------------------------------------------------------------------
  // Text actions
  // ---------------------------------------------------------------------------

  Future<bool> copyText() async {
    final text = _correctedText;
    if (text == null) return false;

    await Clipboard.setData(ClipboardData(text: text));
    return true;
  }

  Future<void> shareText() async {
    final text = _correctedText;
    if (text == null) return;

    await SharePlus.instance.share(
      ShareParams(text: text, title: 'Nepali Sathi'),
    );
  }

  // ---------------------------------------------------------------------------
  // Reset and disposal
  // ---------------------------------------------------------------------------

  Future<void> reset() async {
    _stopTimer();

    try {
      await _audioService.stopPlayback();
      await _speechFeedbackService.stop();

      final path = _audioPath;
      if (path != null) await _deleteFile(path);

      _clearCurrentSession();
      _notify();
    } catch (_) {
      _errorMessage = 'रिसेट गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
      _notify();
    }
  }

  void _clearCurrentSession() {
    _isRecording = false;
    _isProcessing = false;
    _isSpeaking = false;
    _recordingSeconds = 0;
    _audioPath = null;
    _rawText = null;
    _correctedText = null;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTimer();
    unawaited(_audioService.dispose());
    unawaited(_speechFeedbackService.dispose());
    super.dispose();
  }
}
