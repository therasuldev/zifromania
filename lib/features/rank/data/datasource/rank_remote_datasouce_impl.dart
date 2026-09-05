import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/rank/data/datasource/rank_remote_datasouce.dart';

final class RankRemoteDataSourceImpl implements RankRemoteDataSource {
  const RankRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  @override
  Future<List<UserModel>> fetchTopRankedUsers({int limit = 50}) async {
    try {
      final querySnapshot =
          await _firestore.collection(_usersCollection).orderBy('level', descending: true).orderBy('xp', descending: true).limit(limit).get();

      return querySnapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    } on FirebaseException catch (e, st) {
      throw ServerException(
        message: e.message ?? 'Məlumatlar yüklənərkən Firestore xətası baş verdi.',
        statusCode: int.tryParse(e.code),
        error: e,
        stackTrace: st,
      );
    } catch (e, st) {
      throw UnknownException(
        message: 'İstifadəçilər gətirilərkən gözlənilməz xəta baş verdi.',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Stream<List<UserModel>> streamTopRankedUsers({int limit = 50}) {
    return _firestore
        .collection(_usersCollection)
        .orderBy('level', descending: true)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    }).handleError((Object error, StackTrace stackTrace) {
      if (error is FirebaseException) {
        throw ServerException(
          message: error.message ?? 'Liderlər lövhəsi yenilənərkən xəta baş verdi.',
          statusCode: int.tryParse(error.code),
          error: error,
          stackTrace: stackTrace,
        );
      }

      throw UnknownException(
        message: 'Liderlər lövhəsində gözlənilməz xəta baş verdi.',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  @override
  Future<int> getUserRankPosition(String userId) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw const ServerException(message: 'User not found');
      }

      final userData = userDoc.data()!;
      final userLevel = userData['level'] ?? 0;
      final userXp = userData['xp'] ?? 0;

      // Daha böyük level-i olan istifadəçilərin sayı
      final higherLevelQuery = await _firestore.collection(_usersCollection).where('level', isGreaterThan: userLevel).count().get();

      // Eyni level-də olub, daha çox XP-si olan istifadəçilərin sayı
      final sameLevelHigherXpQuery =
          await _firestore.collection(_usersCollection).where('level', isEqualTo: userLevel).where('xp', isGreaterThan: userXp).count().get();

      final higherLevelCount = higherLevelQuery.count ?? 0;
      final sameLevelHigherXpCount = sameLevelHigherXpQuery.count ?? 0;

      return higherLevelCount + sameLevelHigherXpCount + 1;
    } catch (e) {
      throw const ServerException(message: 'Failed to get user rank position');
    }
  }
}
