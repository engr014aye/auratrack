import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Ultra-responsive, zero-latency tactile audio & haptics service.
class SoundService {
  static final SoundService _instance = SoundService._internal();

  factory SoundService() => _instance;

  SoundService._internal() {
    _configureAudioContext();
  }

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  bool get isSoundEnabled => _soundEnabled;

  bool get isHapticsEnabled => _hapticsEnabled;

  void _configureAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
    } catch (_) {}
  }

  void updateSettings({bool? soundEnabled, bool? hapticsEnabled}) {
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (hapticsEnabled != null) _hapticsEnabled = hapticsEnabled;
  }

  /// Instant, zero-latency tactile button click sound
  void playClick() {
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    if (!_soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      player.play(
        AssetSource('sounds/click.wav'),
        volume: 0.5,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  /// Instant un-check / modal pop sound
  void playPop() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      player.play(
        AssetSource('sounds/pop.wav'),
        volume: 0.6,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  /// Instant habit completion chime
  void playChime() {
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      player.play(
        AssetSource('sounds/chime.wav'),
        volume: 0.85,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  /// 100% daily completion victory celebration sound
  void playCelebration() {
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      player.play(
        AssetSource('sounds/celebrate.wav'),
        volume: 0.9,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  void dispose() {}
}
