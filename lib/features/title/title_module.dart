import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/title/data/datasource/title_remote_datasource.dart';
import 'package:zifromania/features/title/data/datasource/title_remote_datasource_impl.dart';
import 'package:zifromania/features/title/data/repositories/title_repository_impl.dart';
import 'package:zifromania/features/title/domain/repositories/title_repository.dart';
import 'package:zifromania/features/title/domain/usecases/award_title_to_user_usecase.dart';
import 'package:zifromania/features/title/domain/usecases/check_and_award_titles_usecase.dart';
import 'package:zifromania/features/title/domain/usecases/get_all_titles_usecase.dart';
import 'package:zifromania/features/title/domain/usecases/get_user_titles_usecase.dart';

// NOTE: bu iki provider layihənin `user` modulunda artıq mövcud olmalıdır.
// Fərqli adlandırılıbsa, aşağıdakı importları/adları öz layihənizə uyğunlaşdırın.
import 'package:zifromania/features/user/user_module.dart' show userRepositoryProvider, userStatisticsRepositoryProvider;

// ---------------------------------------------------------------------------
// Data source
// ---------------------------------------------------------------------------

final titleRemoteDataSourceProvider = Provider<TitleRemoteDataSource>((ref) {
  return TitleRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final titleRepositoryProvider = Provider<TitleRepository>((ref) {
  return TitleRepositoryImpl(
    remoteDataSource: ref.watch(titleRemoteDataSourceProvider),
  );
});

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

final getAllTitlesUseCaseProvider = Provider<GetAllTitlesUseCase>((ref) {
  return GetAllTitlesUseCase(ref.watch(titleRepositoryProvider));
});

final getUserTitlesUseCaseProvider = Provider<GetUserTitlesUseCase>((ref) {
  return GetUserTitlesUseCase(
    titleRepository: ref.watch(titleRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final awardTitleToUserUseCaseProvider = Provider<AwardTitleToUserUseCase>((ref) {
  return AwardTitleToUserUseCase(ref.watch(userStatisticsRepositoryProvider));
});

final checkAndAwardTitlesUseCaseProvider = Provider<CheckAndAwardTitlesUseCase>((ref) {
  return CheckAndAwardTitlesUseCase(
    titleRepository: ref.watch(titleRepositoryProvider),
    userStatisticsRepository: ref.watch(userStatisticsRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    awardTitleToUserUseCase: ref.watch(awardTitleToUserUseCaseProvider),
  );
});
