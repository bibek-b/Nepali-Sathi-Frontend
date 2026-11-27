import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TranscriptionStatus extends StatelessWidget {
  final bool isProcessing;
  final String? errorMessage;
  final bool canRetryCorrection;
  final VoidCallback onRetry;

  const TranscriptionStatus({
    super.key,
    required this.isProcessing,
    required this.errorMessage,
    required this.canRetryCorrection,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isProcessing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'तपाईंको बोलीलाई लेखाइमा परिवर्तन गर्दैछौँ...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.error, width: 1.2),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.alertCircle, color: colors.error, size: 30),
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(
                canRetryCorrection
                    ? 'लेखाइ फेरि सुधार गर्नुहोस्'
                    : 'फेरि प्रयास गर्नुहोस्',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
