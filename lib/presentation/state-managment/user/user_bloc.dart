import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zifromania/models/user_model.dart';
import 'package:zifromania/services/cache_service.dart';
import 'package:zifromania/services/user_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SecureCacheService _cacheService;
  final UserService _userService;
  UserBloc({required SecureCacheService cacheService, required UserService userService})
      : _cacheService = cacheService,
        _userService = userService,
        super(UserState.initial()) {
    on<UserEvent>((event, emit) async {
      switch (event.event) {
        case UserEvents.spendCoinForGameStart:
          await _onSpendCoinForGameStart(event, emit);
          break;
        case UserEvents.loadCachedUserStart:
          await _onLoadCachedUser(emit);
          break;
        case UserEvents.grantCoinsStart:
          await _onGrantCoinsStart(event, emit);
        default:
          break;
      }
    });
  }

  Future<void> _onSpendCoinForGameStart(UserEvent event, Emitter<UserState> emit) async {
    emit(UserState(event: UserEvents.spendCoinForGameStart));
    try {
      final coinAmount = event.type as int;

      // Get current user from cache
      final currentUser = await _cacheService.read<UserModel>('user');

      if (currentUser == null) {
        emit(UserState(event: UserEvents.spendCoinForGameFailure, user: null, error: 'User not found'));
        return;
      }

      // Check if user has enough coins
      if (currentUser.coins < coinAmount) {
        emit(UserState(event: UserEvents.spendCoinForGameFailure, user: currentUser, error: 'Not enough coins'));
        return;
      }

      // Spend coins
      await _userService.spendCoins(currentUser.uid, coinAmount);

      // Update user coins locally
      final updatedUser = currentUser.copyWith(coins: currentUser.coins - coinAmount);

      // Save updated user to cache
      await _cacheService.write<UserModel>('user', updatedUser);

      emit(UserState(event: UserEvents.spendCoinForGameSuccess, user: updatedUser));
    } catch (e) {
      emit(UserState(event: UserEvents.spendCoinForGameFailure, user: null, error: 'Failed to spend coins: $e'));
    }
  }

  Future<void> _onLoadCachedUser(Emitter<UserState> emit) async {
    emit(UserState(event: UserEvents.loadCachedUserStart, user: null, error: null));
    try {
      final cachedUser = await _cacheService.read<UserModel>('user');

      if (cachedUser == null) {
        emit(UserState(event: UserEvents.loadCachedUserFailure, user: null, error: 'User not found in cache'));
        return;
      }

      emit(UserState(event: UserEvents.loadCachedUserSuccess, user: cachedUser));
    } catch (e) {
      emit(UserState(event: UserEvents.loadCachedUserFailure, user: null, error: 'Failed to load cached user: $e'));
    }
  }

  Future<void> _onGrantCoinsStart(UserEvent event, Emitter<UserState> emit) async {
    emit(UserState(event: UserEvents.grantCoinsStart));
    try {
      final coinAmount = event.type as int;

      // Get current user from cache
      final currentUser = await _cacheService.read<UserModel>('user');

      if (currentUser == null) {
        emit(UserState(event: UserEvents.spendCoinForGameFailure, user: null, error: 'User not found'));
        return;
      }

      // Grant coins
      final updatedUser = currentUser.copyWith(coins: currentUser.coins + coinAmount);

      // Update user in the database
      final user = await _userService.addCoins(currentUser.uid, coinAmount);
      // Save updated user to cache
      await _cacheService.write<UserModel>('user', user);

      emit(UserState(user: updatedUser));
    } catch (e) {
      emit(UserState(event: UserEvents.grantCoinsStart, user: null, error: 'Failed to grant coins: $e'));
    }
  }
}
