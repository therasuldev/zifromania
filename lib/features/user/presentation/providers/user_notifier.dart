import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/features/user/domain/entities/user_entity.dart';
import 'package:zifromania/features/user/user_module.dart';

final userProvider = StreamProvider.family<UserEntity, String>(
  (ref, uid) {
    final watchUser = ref.watch(watchUserUseCaseProvider);

    return watchUser(uid);
  },
);
