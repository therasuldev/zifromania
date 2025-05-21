import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/user_service.dart';

class TitleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _titlesCollection = 'titles';
  final UserService _userService = UserService();

  // Get all available titles
  Future<List<TitleModel>> getAllTitles() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_titlesCollection).get();

      return snapshot.docs.map((doc) {
        return TitleModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error getting titles: $e');
      throw Exception('Failed to get titles: $e');
    }
  }

  // Get specific title by ID
  Future<TitleModel> getTitleById(String titleId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_titlesCollection).doc(titleId).get();

      if (doc.exists) {
        return TitleModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      } else {
        throw Exception('Title not found');
      }
    } catch (e) {
      print('Error getting title: $e');
      throw Exception('Failed to get title: $e');
    }
  }

  // Get titles earned by a user
  Future<List<TitleModel>> getUserTitles(String uid) async {
    try {
      // Get user data
      final UserModel user = await _userService.fetchFullUser(uid);

      // Get title IDs from user's achievements
      final List<String> titleIds = user.achievements;

      if (titleIds.isEmpty) {
        return [];
      }

      // Fetch title details for each ID
      final List<TitleModel> titles = [];
      for (final titleId in titleIds) {
        try {
          final title = await getTitleById(titleId);
          titles.add(title);
        } catch (e) {
          print('Error fetching title $titleId: $e');
          // Continue with next title
        }
      }

      return titles;
    } catch (e) {
      print('Error getting user titles: $e');
      throw Exception('Failed to get user titles: $e');
    }
  }

  // Award a title to a user
  Future<void> awardTitleToUser(String uid, String titleId) async {
    try {
      await _userService.addAchievement(uid, titleId);
    } catch (e) {
      print('Error awarding title: $e');
      throw Exception('Failed to award title: $e');
    }
  }
}
