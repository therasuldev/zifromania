// settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/services/settings_service.dart';
import 'package:zifromania/services/sound_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final SoundService _soundService;

  SettingsBloc({
    SettingsService? settingsService,
    SoundService? soundService,
  })  : _settingsService = settingsService ?? SettingsService(),
        _soundService = soundService ?? SoundService(),
        super(SettingsState.initial()) {
    on<SettingsEvent>((event, emit) async {
      switch (event.type) {
        case SettingsEvents.loadSettings:
          await _onLoadSettings(event, emit);
          break;
        case SettingsEvents.toggleSound:
          await _onToggleSound(event, emit);
          break;
        case SettingsEvents.toggleMusic:
          await _onToggleMusic(event, emit);
          break;
        case SettingsEvents.toggleVibration:
          await _onToggleVibration(event, emit);
          break;
        case SettingsEvents.resetSettings:
          await _onResetSettings(event, emit);
          break;
        case SettingsEvents.playBackgroundMusic:
          await _onPlayBackgroundMusic(event, emit);
          break;
        case SettingsEvents.stopBackgroundMusic:
          await _onStopBackgroundMusic(event, emit);
          break;
        case SettingsEvents.playClickSound:
          await _onPlayClickSound(event, emit);
          break;
        case SettingsEvents.vibrate:
          await _onVibrate(event, emit);
          break;
        case SettingsEvents.setLanguage:
          await _onSetLanguage(event, emit);
          break;
        case SettingsEvents.getLanguage:
          _onGetLanguage(emit);
          break;
      }
    });

    // Initialize settings and sound service when the bloc is created
    add(SettingsEvent.loadSettings());
  }

  Future<void> _onLoadSettings(SettingsEvent event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isLoading: true));

    await _settingsService.init();
    await _soundService.init();

    final soundEnabled = _settingsService.getSoundEnabled();
    final musicEnabled = _settingsService.getMusicEnabled();
    final vibrationEnabled = _settingsService.getVibrationEnabled();

    emit(state.copyWith(
      soundEnabled: soundEnabled,
      musicEnabled: musicEnabled,
      vibrationEnabled: vibrationEnabled,
      isLoading: false,
    ));
  }

  Future<void> _onToggleSound(SettingsEvent event, Emitter<SettingsState> emit) async {
    final enabled = event.payload as bool;
    await _settingsService.setSoundEnabled(enabled);
    emit(state.copyWith(soundEnabled: enabled));
  }

  Future<void> _onToggleMusic(
    SettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final enabled = event.payload as bool;
    await _settingsService.setMusicEnabled(enabled);

    if (!enabled && _soundService.isMusicPlaying) {
      await _soundService.pauseBackgroundMusic(); // və ya stop
    } else if (enabled && _soundService.isMusicPaused) {
      await _soundService.resumeBackgroundMusic();
    }

    emit(state.copyWith(musicEnabled: enabled));
  }

  Future<void> _onToggleVibration(SettingsEvent event, Emitter<SettingsState> emit) async {
    final enabled = event.payload as bool;
    await _settingsService.setVibrationEnabled(enabled);
    emit(state.copyWith(vibrationEnabled: enabled));
  }

  Future<void> _onResetSettings(SettingsEvent event, Emitter<SettingsState> emit) async {
    await _settingsService.resetToDefaults();
    emit(state.copyWith(
      soundEnabled: SettingsService.defaultSoundEnabled,
      musicEnabled: SettingsService.defaultMusicEnabled,
      vibrationEnabled: SettingsService.defaultVibrationEnabled,
    ));
  }

  Future<void> _onPlayBackgroundMusic(SettingsEvent event, Emitter<SettingsState> emit) async {
    final assetPath = event.payload as String;
    await _soundService.playBackgroundMusic(assetPath);
  }

  Future<void> _onStopBackgroundMusic(SettingsEvent event, Emitter<SettingsState> emit) async {
    await _soundService.stopBackgroundMusic();
  }

  Future<void> _onPlayClickSound(SettingsEvent event, Emitter<SettingsState> emit) async {
    final assetPath = event.payload as String;
    await _soundService.playSoundEffect(assetPath);
  }

  Future<void> _onVibrate(SettingsEvent event, Emitter<SettingsState> emit) async {
    final duration = event.payload as int;
    await _soundService.vibrate(duration: duration);
  }

  Future<void> _onSetLanguage(SettingsEvent event, Emitter<SettingsState> emit) async {
    final language = event.payload as String;
    await _settingsService.setLanguage(language);
    emit(state.copyWith(language: language));
  }

  void _onGetLanguage(Emitter<SettingsState> emit) {
    final language = _settingsService.getLanguage();
    emit(state.copyWith(language: language));
  }
}
