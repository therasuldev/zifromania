import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/title/title_module.dart';
import 'package:zifromania/features/title/domain/entities/title_entity.dart';

final allTitlesProvider = AsyncNotifierProvider<AllTitlesNotifier, List<TitleEntity>>(
  AllTitlesNotifier.new,
);

final class AllTitlesNotifier extends AsyncNotifier<List<TitleEntity>> {
  @override
  Future<List<TitleEntity>> build() {
    return ref.watch(getAllTitlesUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(getAllTitlesUseCaseProvider).call(),
    );
  }
}
