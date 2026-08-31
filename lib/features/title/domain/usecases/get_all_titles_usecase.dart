import '../entities/title_entity.dart';
import '../repositories/title_repository.dart';

final class GetAllTitlesUseCase {
  final TitleRepository titleRepository;

  const GetAllTitlesUseCase(this.titleRepository);

  Future<List<TitleEntity>> call() {
    return titleRepository.getAllTitles();
  }
}
