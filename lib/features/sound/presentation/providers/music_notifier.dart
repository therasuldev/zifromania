import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/sound/presentation/state/music_status.dart';
import 'package:zifromania/features/sound/sound_module.dart';

final class MusicNotifier extends Notifier<MusicStatus> {
  @override
  MusicStatus build() {
    return MusicStatus.stopped;
  }

  Future<void> play(String assetPath) async {
    await ref.read(playBackgroundMusicUseCaseProvider).call(assetPath);

    state = MusicStatus.playing;
  }

  Future<void> pause() async {
    await ref.read(pauseBackgroundMusicUseCaseProvider).call();

    state = MusicStatus.paused;
  }

  Future<void> resume() async {
    await ref.read(resumeBackgroundMusicUseCaseProvider).call();

    state = MusicStatus.playing;
  }

  Future<void> stop() async {
    await ref.read(stopBackgroundMusicUseCaseProvider).call();

    state = MusicStatus.stopped;
  }
}

final musicProvider = NotifierProvider<MusicNotifier, MusicStatus>(
  MusicNotifier.new,
);
