import 'package:flutter/material.dart';
import 'package:nepal_sathi_frontend/features/speech_to_text/widgets/transcription_result.dart';

import '../controllers/speech_to_text_controller.dart';
import '../widgets/audio_preview.dart';
import '../widgets/recording_card.dart';
import '../widgets/transcription_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SpeechToTextController _controller;
  final ScrollController _scrollController = ScrollController();

  String? _lastDisplayedText;

  @override
  void initState() {
    super.initState();
    _controller = SpeechToTextController();
    _controller.addListener(_handleControllerChange);
  }

@override
void dispose() {
  _controller.removeListener(_handleControllerChange);
  _controller.dispose();
  _scrollController.dispose();

  super.dispose();
}

  void _handleControllerChange() {
    final correctedText = _controller.correctedText;

    if (correctedText == null) {
      _lastDisplayedText = null;
      return;
    }

    // Avoid scrolling on unrelated state updates.
    if (correctedText == _lastDisplayedText) return;

    _lastDisplayedText = correctedText;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _copyText() async {
    try {
      final copied = await _controller.copyText();
      if (!mounted || !copied) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied successfully!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not copy text.')));
    }
  }

  Future<void> _shareText() async {
    try {
      await _controller.shareText();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not share text.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(22),
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 45),

                RecordingCard(
                  isRecording: _controller.isRecording,
                  isProcessing: _controller.isProcessing,
                  hasRecording: _controller.hasRecording,
                  duration: _controller.formattedDuration,
                  onRecordTap: _controller.handleRecordingButtonTap,
                  onSubmit: _controller.submitRecording,
                ),

                if (_controller.hasRecording &&
                    !_controller.isRecording &&
                    !_controller.isProcessing) ...[
                  AudioPreview(
                    player: _controller.audioPlayer,
                    onTogglePlayback: _controller.togglePlayback,
                    onDelete: _controller.deleteRecording,
                  ),
                ],

                TranscriptionStatus(
                  isProcessing: _controller.isProcessing,
                  errorMessage: _controller.errorMessage,
                  canRetryCorrection: _controller.canRetryCorrection,
                  onRetry: _controller.retry,
                ),

                if (_controller.correctedText != null) ...[
                  const SizedBox(height: 20),
                  TranscriptionResult(
                    text: _controller.correctedText!,
                    onCopy: _copyText,
                    onShare: _shareText,
                    onReset: _controller.reset,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Center(
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
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
