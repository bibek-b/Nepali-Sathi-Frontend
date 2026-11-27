import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RecordingCard extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final bool hasRecording;
  final String duration;
  final VoidCallback onRecordTap;
  final VoidCallback onSubmit;

  const RecordingCard({
    super.key,
    required this.isRecording,
    required this.isProcessing,
    required this.hasRecording,
    required this.duration,
    required this.onRecordTap,
    required this.onSubmit,
  });

  @override
  State<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isRecording) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant RecordingCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRecording = widget.isRecording;

    final buttonColor = isRecording ? colors.error : colors.primary;
    final buttonBackground = isRecording
        ? colors.errorContainer
        : colors.primaryContainer;

    final buttonIcon = isRecording
        ? LucideIcons.square
        : widget.hasRecording
        ? LucideIcons.rotateCcw
        : LucideIcons.mic;

    final buttonLabel = isRecording
        ? 'रेकर्डिङ रोक्नुहोस्'
        : widget.hasRecording
        ? 'फेरि रेकर्ड गर्नुहोस्'
        : 'रेकर्ड गर्न थिच्नुहोस्';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'आफ्नो कुरा बोल्नुहोस्',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'नेपाली वा नेपाली + English मा बोल्न सक्नुहुन्छ।',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ScaleTransition(
            scale: isRecording ? _scale : const AlwaysStoppedAnimation(1.0),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.isProcessing ? null : widget.onRecordTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonBackground,
                    border: Border.all(color: buttonColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: 0.18),
                        blurRadius: isRecording ? 28 : 12,
                        spreadRadius: isRecording ? 7 : 2,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      buttonIcon,
                      key: ValueKey(buttonIcon),
                      size: 38,
                      color: buttonColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              buttonLabel,
              key: ValueKey(buttonLabel),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: buttonColor,
              ),
            ),
          ),
          if (widget.isRecording) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  widget.duration,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (widget.hasRecording &&
              !widget.isRecording &&
              !widget.isProcessing) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onSubmit,
                icon: const Icon(LucideIcons.send, size: 20),
                label: const Text('बोली पठाउनुहोस्'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
