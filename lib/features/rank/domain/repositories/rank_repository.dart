import 'package:zifromania/features/user/data/models/user_model.dart';

/// `rank` feature-inin domain qatındakı repository kontraktı.
/// Data qatı (Firestore, cache və s.) bu interfeys arxasında gizlənir,
/// beləliklə domain və presentation qatları konkret data source-dan asılı olmur.
abstract interface class RankRepository {
  /// Ən yüksək reytinqli istifadəçilərin siyahısını bir dəfəlik gətirir.
  Future<List<UserModel>> fetchTopRankedUsers({int limit = 50});

  /// Liderlər lövhəsini real-vaxt rejimində izləyir.
  Stream<List<UserModel>> streamTopRankedUsers({int limit = 50});

  /// Konkret bir istifadəçinin ümumi reytinqdəki mövqeyini qaytarır.
  Future<int> getUserRankPosition(String userId);
}
