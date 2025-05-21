// title_state.dart
part of 'title_bloc.dart';

class TitleState {
  final List<TitleModel> titles;
  final TitleEvents? event;

  TitleState({required this.titles, required this.event});
  factory TitleState.initial() => TitleState(titles: [], event: null);
}
