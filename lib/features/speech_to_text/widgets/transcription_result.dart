
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TranscriptionResult extends StatelessWidget {
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onReset;

  const TranscriptionResult({
    super.key,
    required this.text,
    required this.onCopy,
    required this.onShare,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                LucideIcons.checkCircle,
                color: Color(0xFF16845B),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'तपाईंको लेखाइ तयार छ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SelectableText(
            text,
            style: const TextStyle(
              fontSize: 18,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(LucideIcons.copy, size: 17),
                  label: const Text('Copy'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(LucideIcons.share2, size: 17),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('अर्को रेकर्डिङ गर्नुहोस्'),
            ),
          ),
        ],
      ),
    );
  }
}
