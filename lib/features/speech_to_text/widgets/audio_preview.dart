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
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.audioLines,
                color: Color(0xFF16845B),
                size: 22,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Your recording',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),

              _buildPlaybackButton(),

              IconButton(
                tooltip: 'Delete recording',
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2, color: Colors.red),
              ),
            ],
          ),

          _buildPlaybackProgress(),
        ],
      ),
    );
  }

  Widget _buildPlaybackButton() {
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
          onPressed: isLoading ? null : onTogglePlayback,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
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
            backgroundColor: const Color(0xFF16845B),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildPlaybackProgress() {
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
                  activeColor: const Color(0xFF16845B),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(position)),
                      Text(_formatDuration(duration)),
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
