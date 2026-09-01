import 'package:zifromania/features/title/data/datasource/title_remote_datasource.dart';

import '../../domain/entities/title_entity.dart';
import '../../domain/repositories/title_repository.dart';

final class TitleRepositoryImpl implements TitleRepository {
  final TitleRemoteDataSource remoteDataSource;

  const TitleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TitleEntity>> getAllTitles() => remoteDataSource.getAllTitles();

  @override
  Future<TitleEntity> getTitleById(String titleId) => remoteDataSource.getTitleById(titleId);

  @override
  Future<List<TitleEntity>> getTitlesByIds(List<String> titleIds) => remoteDataSource.getTitlesByIds(titleIds);
}
