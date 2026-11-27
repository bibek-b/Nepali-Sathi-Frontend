import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AudioPreview extends StatelessWidget {
  final AudioPlayer player;
  final VoidCallback onTogglePlayback;
  final VoidCallback onDelete;

  const AudioPreview({
    super.key,
    required this.player,
    required this.onTogglePlayback,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(LucideIcons.audioLines, color: colors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'तपाईंको रेकर्डिङ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildPlaybackButton(context),
              IconButton(
                tooltip: 'रेकर्डिङ हटाउनुहोस्',
                onPressed: onDelete,
                icon: Icon(LucideIcons.trash2, color: colors.error),
              ),
            ],
          ),
          _buildPlaybackProgress(context),
        ],
      ),
    );
  }

  Widget _buildPlaybackButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;
        final processingState = state?.processingState;
        final isCompleted = processingState == ProcessingState.completed;
        final isLoading =
            processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering;

        return IconButton.filled(
          tooltip: isCompleted ? 'फेरि सुन्नुहोस्' : 'रेकर्डिङ सुन्नुहोस्',
          onPressed: isLoading ? null : onTogglePlayback,
          icon: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isCompleted
                      ? LucideIcons.rotateCcw
                      : isPlaying
                      ? LucideIcons.pause
                      : LucideIcons.play,
                ),
          style: IconButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
        );
      },
    );
  }

  Widget _buildPlaybackProgress(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            final maxMilliseconds = duration.inMilliseconds > 0
                ? duration.inMilliseconds.toDouble()
                : 1.0;
            final currentMilliseconds = position.inMilliseconds
                .clamp(0, maxMilliseconds.toInt())
                .toDouble();

            return Column(
              children: [
                Slider(
                  value: currentMilliseconds,
                  max: maxMilliseconds,
                  onChanged: duration.inMilliseconds > 0
                      ? (value) {
                          player.seek(Duration(milliseconds: value.round()));
                        }
                      : null,
                  activeColor: colors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: TextStyle(color: colors.onSurface),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
