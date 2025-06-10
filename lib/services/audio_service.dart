import 'package:audioplayers/audioplayers.dart';

class AudioService {
  late AudioPlayer _audioPlayer;

  AudioService() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    await _audioPlayer.release();
  }

  Future<void> playSoundEffect(bool isCorrect) async {
    if (isCorrect) {
      await _audioPlayer.play(AssetSource('sounds/correct_sound.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/wrong_sound.mp3'));
    }
  }

  // Future<void> dispose() async {
  //   await _audioPlayer.dispose();
  // }
}
