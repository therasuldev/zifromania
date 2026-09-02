import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/title/title_module.dart';
import 'package:zifromania/features/title/domain/entities/title_entity.dart';

final userTitlesProvider = AsyncNotifierProvider.family<UserTitlesNotifier, List<TitleEntity>, String>(
  UserTitlesNotifier.new,
);

final class UserTitlesNotifier extends AsyncNotifier<List<TitleEntity>> {
  UserTitlesNotifier(this.uid);

  final String uid;

  @override
  Future<List<TitleEntity>> build() {
    return ref.watch(getUserTitlesUseCaseProvider).call(uid);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getUserTitlesUseCaseProvider).call(uid),
    );
  }
}
