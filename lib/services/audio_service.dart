import 'package:audioplayers/audioplayers.dart';

class AudioService {
  late AudioPlayer _audioPlayer;

  AudioService() {
    _audioPlayer = AudioPlayer();
  }

  void reset() {
    _audioPlayer.dispose();
    _audioPlayer = AudioPlayer();
  }

  Future<void> playSoundEffect(bool isCorrect) async {
    if (isCorrect) {
      await _audioPlayer.play(AssetSource('sounds/correct_sound.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/wrong_sound.mp3'));
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
