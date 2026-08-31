import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';

import 'rank_remote_datasouce.dart';

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
    } catch (e) {
      throw ServerException('Failed to fetch top ranked users: $e');
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
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    }).handleError((error) {
      throw ServerException('Error in top ranked stream: $error');
    });
  }

  @override
  Future<int> getUserRankPosition(String userId) async {
    try {
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw const ServerException('User not found');
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
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get user rank position: $e');
    }
  }
}
