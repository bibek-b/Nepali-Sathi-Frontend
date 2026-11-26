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
    if (isProcessing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF16845B)),
            SizedBox(height: 15),
            Text(
              'तपाईंको बोलीलाई लेखाइमा परिवर्तन गर्दैछौँ...',
              textAlign: TextAlign.center,
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
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertCircle, color: Colors.orange, size: 28),
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 17),
              label: Text(
                canRetryCorrection
                    ? 'लेखाइ फेरि सुधार गर्नुहोस्'
                    : 'फेरि प्रयास गर्नुहोस्',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16845B),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
