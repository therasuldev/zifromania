part of 'user_bloc.dart';

class UserState {
  final UserEvents? event;
  final UserModel? user;
  final String? error;

  UserState({this.event, this.user, this.error});
  factory UserState.initial() => UserState(event: null, user: null, error: null);
}
