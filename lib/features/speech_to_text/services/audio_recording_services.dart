import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _loadedAudioPath;

  AudioPlayer get player => _player;

  Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) return false;

    // Stop any previous playback.
    await _player.stop();
    _loadedAudioPath = null;

    final directory = await getTemporaryDirectory();

    final path =
        '${directory.path}/nepali_sathi_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    return true;
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  Future<void> togglePlayback(String audioPath) async {
    // Load the audio file if it isn't already loaded.
    if (_loadedAudioPath != audioPath) {
      await _player.setFilePath(audioPath);
      _loadedAudioPath = audioPath;
    }

    // Replay if playback has completed.
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      unawaited(_player.play());
      return;
    }

    if (_player.playing) {
      await _player.pause();
    } else {
      unawaited(_player.play());
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _loadedAudioPath = null;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
