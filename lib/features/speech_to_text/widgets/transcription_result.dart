import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TranscriptionResult extends StatelessWidget {
  final String text;
  final bool isSpeaking;
  final VoidCallback onSpeak;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const TranscriptionResult({
    super.key,
    required this.text,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onCopy,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.checkCircle, color: colors.primary, size: 22),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'तपाईंको लेखाइ तयार छ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SelectableText(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontSize: 20,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(LucideIcons.copy, size: 18),
                label: const Text('कपी गर्नुहोस्'),
              ),
              OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(LucideIcons.share2, size: 18),
                label: const Text('सेयर गर्नुहोस्'),
              ),
              ElevatedButton.icon(
                onPressed: onSpeak,
                icon: Icon(
                  isSpeaking ? LucideIcons.square : LucideIcons.volume2,
                  size: 18,
                ),
                label: Text(isSpeaking ? 'रोक्नुहोस्' : 'सुनाउनुहोस्'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('अर्को रेकर्डिङ गर्नुहोस्'),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                minimumSize: const Size(0, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
