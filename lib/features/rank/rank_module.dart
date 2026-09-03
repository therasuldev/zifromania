import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/features/rank/data/datasource/rank_remote_datasouce.dart';
import 'package:zifromania/features/rank/data/datasource/rank_remote_datasouce_impl.dart';
import 'package:zifromania/features/rank/data/repositories/rank_repository_impl.dart';
import 'package:zifromania/features/rank/domain/repositories/rank_repository.dart';
import 'package:zifromania/features/rank/domain/usecases/fetch_top_ranked_users.dart';
import 'package:zifromania/features/rank/domain/usecases/get_user_rank_position.dart';
import 'package:zifromania/features/rank/domain/usecases/stream_top_ranked_users.dart';

/// `rank` feature-inin composition root-u.
///
/// Bu fayl data source -> repository -> usecase zəncirini bir yerə toplayır,
/// beləliklə presentation qatı heç bir konkret implementasiyanı (Firestore və s.)
/// bilmədən yalnız usecase provider-lərindən istifadə edir.
///
/// Qeyd: [RankRemoteDataSourceImpl] faylının adı `rank_remote_datasource_impl.dart`
/// olduğunu fərz etdim — sənin layihəndə fərqli adlanırsa import yolunu ona uyğun düzəlt.

final rankRemoteDataSourceProvider = Provider<RankRemoteDataSource>((ref) {
  return RankRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final rankRepositoryProvider = Provider<RankRepository>((ref) {
  final remoteDataSource = ref.watch(rankRemoteDataSourceProvider);
  return RankRepositoryImpl(remoteDataSource: remoteDataSource);
});

final fetchTopRankedUsersUseCaseProvider = Provider<FetchTopRankedUsersUseCase>((ref) {
  return FetchTopRankedUsersUseCase(ref.watch(rankRepositoryProvider));
});

final streamTopRankedUsersUseCaseProvider = Provider<StreamTopRankedUsersUseCase>((ref) {
  return StreamTopRankedUsersUseCase(ref.watch(rankRepositoryProvider));
});

final getUserRankPositionUseCaseProvider = Provider<GetUserRankPositionUseCase>((ref) {
  return GetUserRankPositionUseCase(ref.watch(rankRepositoryProvider));
});
