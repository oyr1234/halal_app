import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playClick(bool enabled) async {
    if (!enabled) return;

    await _player.play(AssetSource('sounds/click.mp3'));
  }
}