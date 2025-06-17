part of 'user_bloc.dart';

enum UserEvents {
  spendCoinForGameStart,
  spendCoinForGameSuccess,
  spendCoinForGameFailure,

  loadCachedUserStart,
  loadCachedUserSuccess,
  loadCachedUserFailure,

  grantCoinsStart,
}

class UserEvent {
  final UserEvents event;
  dynamic type;

  UserEvent.spendCoinForGameStart(int coinAmount)
      : event = UserEvents.spendCoinForGameStart,
        type = coinAmount;

  UserEvent.loadCachedUser()
      : event = UserEvents.loadCachedUserStart,
        type = null;

  UserEvent.grantCoinsStart(int coinAmount)
      : event = UserEvents.grantCoinsStart,
        type = coinAmount;

  
}
