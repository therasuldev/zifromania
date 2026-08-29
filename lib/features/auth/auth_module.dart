import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zifromania/core/providers/firebase_provider.dart';
import 'package:zifromania/core/services/secure_storage_service.dart';
import 'package:zifromania/features/auth/data/datasource/auth_remote_datasource_impl.dart';
import 'package:zifromania/features/auth/domain/repositories/auth_repository.dart';
import 'package:zifromania/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:zifromania/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:zifromania/features/auth/domain/usecases/get_current_user_usecase.dart';

import 'data/datasource/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';

final secureCacheServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(
    auth: ref.read(authProvider),
    cacheService: ref.read(secureCacheServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDatasourceProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});
