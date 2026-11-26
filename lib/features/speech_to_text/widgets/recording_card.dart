
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
    final buttonColor = widget.isRecording
        ? Colors.red
        : const Color(0xFF16845B);

    final buttonBackground = widget.isRecording
        ? const Color(0xFFFFEEEE)
        : const Color(0xFFE5F4EC);

    final buttonIcon = widget.isRecording
        ? LucideIcons.square
        : widget.hasRecording
        ? LucideIcons.rotateCcw
        : LucideIcons.mic;

    final buttonLabel = widget.isRecording
        ? 'Tap to stop recording'
        : widget.hasRecording
        ? 'Record again'
        : 'Tap to start recording';

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'आफ्नो कुरा बोल्नुहोस्',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            'नेपाली वा नेपाली + English मा बोल्न सक्नुहुन्छ।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 35),
          ScaleTransition(
            scale: widget.isRecording
                ? _scale
                : const AlwaysStoppedAnimation(1.0),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.isProcessing ? null : widget.onRecordTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                        blurRadius: widget.isRecording ? 28 : 12,
                        spreadRadius: widget.isRecording ? 7 : 2,
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
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              buttonLabel,
              key: ValueKey(buttonLabel),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.duration,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
          if (widget.hasRecording &&
              !widget.isRecording &&
              !widget.isProcessing) ...[
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onSubmit,
                icon: const Icon(LucideIcons.send, size: 18),
                label: const Text('बोली पठाउनुहोस्'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16845B),
                  foregroundColor: Colors.white,
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
