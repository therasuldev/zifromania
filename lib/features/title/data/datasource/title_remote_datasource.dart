import 'package:zifromania/features/title/data/models/title_model.dart';

abstract interface class TitleRemoteDataSource {
  Future<List<TitleModel>> getAllTitles();

  Future<TitleModel> getTitleById(String titleId);
  
  Future<List<TitleModel>> getTitlesByIds(List<String> titleIds);
}