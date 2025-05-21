// title_event.dart
part of 'title_bloc.dart';

enum TitleEvents {
  fetchAllTitlesStart,
  fetchAllTitlesSuccess,
  fetchAllTitlesFailure,
  fetchUserTitlesStart,
  fetchUserTitlesSuccess,
  fetchUserTitlesFailure,
  awardTitleStart,
  awardTitleSuccess,
  awardTitleFailure,
}

class TitleEvent {
  TitleEvents? type;
  dynamic payload;

  TitleEvent.fetchAllTitlesStart() {
    type = TitleEvents.fetchAllTitlesStart;
  }

  TitleEvent.fetchUserTitlesStart({required this.payload}) {
    type = TitleEvents.fetchUserTitlesStart;
  }

  TitleEvent.awardTitleStart({required this.payload}) {
    type = TitleEvents.awardTitleStart;
  }
}
