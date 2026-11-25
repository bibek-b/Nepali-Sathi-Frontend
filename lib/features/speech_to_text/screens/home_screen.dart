
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nepal_sathi_frontend/features/speech_to_text/services/audio_recording_services.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/audio_preview.dart';
import '../widgets/recording_card.dart';
import '../widgets/transcription_result.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Services
  final AudioRecordingService _audioService =
      AudioRecordingService();

  // Animation
  late final AnimationController _recordingController;
  late final Animation<double> _recordingScale;

  // Timer
  Timer? _timer;

  // Screen state
  bool _isRecording = false;
  bool _isProcessing = false;

  String? _audioPath;
  String? _correctedText;

  int _recordingSeconds = 0;

  // ============================================================
  // GETTERS
  // ============================================================

  String get _formattedDuration {
    final minutes = (_recordingSeconds ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_recordingSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _recordingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _recordingScale = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: _recordingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordingController.dispose();

    unawaited(_audioService.dispose());

    super.dispose();
  }

  // ============================================================
  // RECORDING
  // ============================================================

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioService.startRecording();

      if (!mounted) {
        if (hasPermission) {
          await _audioService.stopRecording();
        }
        return;
      }

      if (!hasPermission) {
        _showMessage('Microphone permission is required.');
        return;
      }

      setState(() {
        _isRecording = true;
        _audioPath = null;
        _correctedText = null;
        _recordingSeconds = 0;
      });

      _recordingController.repeat(reverse: true);

      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (mounted) {
            setState(() => _recordingSeconds++);
          }
        },
      );
    } catch (e) {
      _stopRecordingAnimation();

      if (mounted) {
        setState(() => _isRecording = false);
        _showMessage('Could not start recording.');
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _stopRecordingAnimation();

    try {
      final path = await _audioService.stopRecording();

      if (!mounted) return;

      if (path == null) {
        setState(() => _isRecording = false);
        _showMessage('Recording could not be saved.');
        return;
      }

      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        _showMessage('Could not stop recording.');
      }
    }
  }

  void _stopRecordingAnimation() {
    _recordingController.stop();
    _recordingController.value = 0;
  }

  Future<void> _deleteRecording() async {
  final path = _audioPath;

  try {
    await _audioService.stopPlayback();

    if (path != null) {
      await File(path).delete();
    }

    if (!mounted) return;

    setState(() {
      _audioPath = null;
      _correctedText = null;
      _recordingSeconds = 0;
    });
  } catch (e) {
    _showMessage('Could not delete recording.');
  }
}

  Future<void> _handleRecordingTap() async {
    if (_isProcessing) return;

    if (_isRecording) {
      await _stopRecording();
    } else if (_audioPath != null) {
      await _reset();
    } else {
      await _startRecording();
    }
  }

  // ============================================================
  // TRANSCRIPTION
  // ============================================================

  Future<void> _submitRecording() async {
    if (_audioPath == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // TODO: Replace with actual backend integration.
      //
      // Expected response:
      // {
      //   "rawText": "...",
      //   "correctedText": "..."
      // }

      await Future.delayed(const Duration(seconds: 2));

      const demoResult =
          'आज मौसम धेरै राम्रो छ। सबैलाई शुभ दिन!';

      if (!mounted) return;

      setState(() {
        _correctedText = demoResult;
      });
    } catch (e) {
      _showMessage(
        'आवाज बुझ्न सकिएन। कृपया फेरि प्रयास गर्नुहोस्।',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ============================================================
  // TEXT ACTIONS
  // ============================================================

  Future<void> _copyText() async {
    if (_correctedText == null) return;

    await Clipboard.setData(
      ClipboardData(text: _correctedText!),
    );

    _showMessage('Text copied successfully!');
  }

  Future<void> _shareText() async {
    if (_correctedText == null) return;

    await SharePlus.instance.share(
      ShareParams(
        text: _correctedText!,
        title: 'Nepali Sathi',
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> _reset() async {
    _timer?.cancel();
    _stopRecordingAnimation();
    _deleteRecording();

    await _audioService.stopPlayback();

    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _isProcessing = false;
      _audioPath = null;
      _correctedText = null;
      _recordingSeconds = 0;
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 16),

            // Header
            const Center(
              child: Column(
                children: [
                  Text(
                    'Nepali Sathi',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'बोल्नुहोस्, हामी नेपालीमा लेख्छौँ।',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 45),

            // Recording
            RecordingCard(
              isRecording: _isRecording,
              isProcessing: _isProcessing,
              hasRecording: _audioPath != null,
              duration: _formattedDuration,
              recordingScale: _recordingScale,
              onRecordTap: _handleRecordingTap,
              onSubmit: _submitRecording,
            ),

            // Audio preview
            if (_audioPath != null && !_isRecording) ...[
              AudioPreview(
                player: _audioService.player,
                onTogglePlayback: () {
                  _audioService.togglePlayback(_audioPath!);
                },
                 onDelete: _deleteRecording,
              ),
            ],

            const SizedBox(height: 25),

            // Processing indicator
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF16845B),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'तपाईंको बोलीलाई लेखाइमा परिवर्तन गर्दैछौँ...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

            // Transcription result
            if (_correctedText != null)
              TranscriptionResult(
                text: _correctedText!,
                onCopy: _copyText,
                onShare: _shareText,
                onReset: _reset,
              ),
          ],
        ),
      ),
    );
  }
}
