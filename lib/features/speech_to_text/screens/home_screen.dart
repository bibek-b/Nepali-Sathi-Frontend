import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../controllers/accessibility_settings_controller.dart';
import '../controllers/speech_to_text_controller.dart';
import '../widgets/accessibility_settings_sheet.dart';
import '../widgets/audio_preview.dart';
import '../widgets/recording_card.dart';
import '../widgets/transcription_result.dart';
import '../widgets/transcription_status.dart';

class HomeScreen extends StatefulWidget {
  final AccessibilitySettingsController accessibilitySettings;

  const HomeScreen({super.key, required this.accessibilitySettings});

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
    widget.accessibilitySettings.addListener(_syncAccessibilitySettings);
    _syncAccessibilitySettings();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.accessibilitySettings != widget.accessibilitySettings) {
      oldWidget.accessibilitySettings.removeListener(
        _syncAccessibilitySettings,
      );
      widget.accessibilitySettings.addListener(_syncAccessibilitySettings);
      _syncAccessibilitySettings();
    }
  }

  void _syncAccessibilitySettings() {
    _controller.setVoiceFeedbackEnabled(
      widget.accessibilitySettings.voiceStatusEnabled,
    );
  }

  @override
  void dispose() {
    widget.accessibilitySettings.removeListener(_syncAccessibilitySettings);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToNewResultIfNeeded() {
    final text = _controller.correctedText;

    if (text == null) {
      _lastDisplayedText = null;
      return;
    }

    if (text == _lastDisplayedText) return;
    _lastDisplayedText = text;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _openAccessibilitySettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AccessibilitySettingsSheet(
          controller: widget.accessibilitySettings,
        );
      },
    );
  }

  Future<void> _copyText() async {
    try {
      final copied = await _controller.copyText();
      if (!mounted || !copied) return;

      _showMessage('Text copied successfully!');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not copy text.');
    }
  }

  Future<void> _shareText() async {
    try {
      await _controller.shareText();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not share text.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        _scrollToNewResultIfNeeded();

        return Scaffold(
          body: SafeArea(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(22),
              children: [
                const SizedBox(height: 8),
                _buildHeader(context),
                const SizedBox(height: 32),
                RecordingCard(
                  isRecording: _controller.isRecording,
                  isProcessing: _controller.isProcessing,
                  hasRecording: _controller.hasRecording,
                  duration: _controller.formattedDuration,
                  onRecordTap: _controller.handleRecordingButtonTap,
                  onSubmit: _controller.submitRecording,
                ),
                if (_controller.hasRecording && !_controller.isRecording)
                  AudioPreview(
                    player: _controller.audioPlayer,
                    onTogglePlayback: _controller.togglePlayback,
                    onDelete: _controller.deleteRecording,
                  ),
                const SizedBox(height: 12),
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
                    isSpeaking: _controller.isSpeaking,
                    onSpeak: _controller.toggleSpeakCorrectedText,
                    onCopy: _copyText,
                    onShare: _shareText,
                    onReset: _controller.reset,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            children: [
              Text(
                'Nepali Sathi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'बोल्नुहोस्, हामी नेपालीमा लेख्छौँ।',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Accessibility settings',
          onPressed: _openAccessibilitySettings,
          icon: const Icon(LucideIcons.settings2),
        ),
      ],
    );
  }
}
