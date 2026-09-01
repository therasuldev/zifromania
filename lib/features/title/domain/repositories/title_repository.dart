import '../entities/title_entity.dart';

abstract interface class TitleRepository {
  Future<List<TitleEntity>> getAllTitles();

  Future<TitleEntity> getTitleById(String titleId);

  Future<List<TitleEntity>> getTitlesByIds(List<String> titleIds);
}
