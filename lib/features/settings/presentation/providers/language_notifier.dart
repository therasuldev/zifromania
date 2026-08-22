import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/settings/settings_module.dart';

final class LanguageNotifier extends Notifier<String> {
  LanguageNotifier() : super();

  @override
  String build() {
    return ref.read(getLanguageUseCaseProvider).call();
  }

  Future<void> setLanguage(String language) async {
    await ref.read(setLanguageUseCaseProvider).call(language);
    state = language;
  }
}

final languageNotifierProvider = NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);
