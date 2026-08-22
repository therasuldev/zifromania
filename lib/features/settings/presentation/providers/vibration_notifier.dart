import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/settings/settings_module.dart';

class VibrationNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.read(getVibrationEnabledUseCaseProvider).call();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await ref.read(setVibrationEnabledUseCaseProvider).call(enabled);
    state = enabled;
  }
}

final vibrationNotifierProvider = NotifierProvider<VibrationNotifier, bool>(
  VibrationNotifier.new,
);
