import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zifromania/features/title/data/models/title_model.dart';

import 'package:zifromania/core/errors/exceptions.dart';
import 'package:zifromania/features/title/data/datasource/title_remote_datasource.dart';

final class TitleRemoteDataSourceImpl implements TitleRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String titlesCollection = 'titles';

  const TitleRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TitleModel>> getAllTitles() async {
    try {
      final snapshot = await firestore.collection(titlesCollection).get();
      return snapshot.docs.map((doc) => TitleModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get titles', error: e);
    }
  }

  @override
  Future<TitleModel> getTitleById(String titleId) async {
    try {
      final doc = await firestore.collection(titlesCollection).doc(titleId).get();
      if (!doc.exists || doc.data() == null) {
        throw const ServerException(message: 'Title not found');
      }
      return TitleModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to get title', error: e);
    }
  }

  @override
  Future<List<TitleModel>> getTitlesByIds(List<String> titleIds) async {
    if (titleIds.isEmpty) return [];

    // Firestore `whereIn` sorğusu maksimum 30 ID dəstəkləyir, ona görə ayrı-ayrı fetch və ya chunking etmək təhlükəsizdir
    final List<TitleModel> titles = [];
    for (final id in titleIds) {
      try {
        final title = await getTitleById(id);
        titles.add(title);
      } catch (_) {
        // Tapılmayan title-ı ötürürük
        continue;
      }
    }
    return titles;
  }
}
