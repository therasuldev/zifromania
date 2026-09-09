import 'package:zifromania/features/user/domain/repositories/user_repository.dart';
import 'package:zifromania/features/title/domain/entities/title_entity.dart';
import 'package:zifromania/features/title/domain/repositories/title_repository.dart';

final class GetUserTitlesUseCase {
  final TitleRepository titleRepository;
  final UserRepository userRepository;

  const GetUserTitlesUseCase({
    required this.titleRepository,
    required this.userRepository,
  });

  Future<List<TitleEntity>> call(String uid) async {
    final user = await userRepository.getUser(uid: uid);
    final List<String> titleIds = user.achievements;

    if (titleIds.isEmpty) {
      return [];
    }

    return titleRepository.getTitlesByIds(titleIds);
  }
}
