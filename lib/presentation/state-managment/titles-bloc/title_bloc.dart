// title_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:zifromania/models/title_model.dart';
import 'package:zifromania/services/title_service.dart';

part 'title_event.dart';
part 'title_state.dart';

class TitleBloc extends Bloc<TitleEvent, TitleState> {
  TitleBloc() : super(TitleState.initial()) {
    on<TitleEvent>((event, emit) async {
      switch (event.type) {
        case TitleEvents.fetchAllTitlesStart:
          await _onFetchAllTitles(event, emit);
          break;
        case TitleEvents.fetchUserTitlesStart:
          await _onFetchUserTitles(event, emit);
          break;
        case TitleEvents.awardTitleStart:
          await _onAwardTitle(event, emit);
          break;
        default:
      }
    });
  }

  final TitleService _titleService = TitleService();

  Future<void> _onFetchAllTitles(TitleEvent event, Emitter<TitleState> emit) async {
    emit(TitleState(titles: [], event: TitleEvents.fetchAllTitlesStart));
    try {
      final titles = await _titleService.getAllTitles();
      emit(TitleState(titles: titles, event: TitleEvents.fetchAllTitlesSuccess));
    } catch (e) {
      emit(TitleState(titles: [], event: TitleEvents.fetchAllTitlesFailure));
    }
  }

  Future<void> _onFetchUserTitles(TitleEvent event, Emitter<TitleState> emit) async {
    emit(TitleState(titles: [], event: TitleEvents.fetchUserTitlesStart));
    try {
      final titles = await _titleService.getUserTitles(event.payload);
      emit(TitleState(titles: titles, event: TitleEvents.fetchUserTitlesSuccess));
    } catch (e) {
      emit(TitleState(titles: [], event: TitleEvents.fetchUserTitlesFailure));
    }
  }

  Future<void> _onAwardTitle(TitleEvent event, Emitter<TitleState> emit) async {
    emit(TitleState(titles: state.titles, event: TitleEvents.awardTitleStart));
    try {
      final data = event.payload as Map<String, String>;
      await _titleService.awardTitleToUser(data['uid']!, data['titleId']!);
      emit(TitleState(titles: state.titles, event: TitleEvents.awardTitleSuccess));
    } catch (e) {
      emit(TitleState(titles: state.titles, event: TitleEvents.awardTitleFailure));
    }
  }
}
