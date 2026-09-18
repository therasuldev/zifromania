// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameState {
  List<MathQuestion> get questions;
  int get currentQuestionIndex;
  int get score;
  int get xpEarned;
  int get secondsRemaining;
  bool get isLoading;
  bool get isGameActive;
  int? get lastSelectedAnswer;
  int? get lastAnsweredQuestionIndex;
  bool? get isLastAnswerCorrect;
  AppException? get appException;
  DateTime? get gameStartTime;
  bool get showResultDialog;
  GameCategory? get gameCategory;
  List<TitleModel> get newlyEarnedTitles;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GameStateCopyWith<GameState> get copyWith =>
      _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as GameState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GameState &&
            const DeepCollectionEquality()
                .equals(other.questions, _this.questions) &&
            (identical(
                    other.currentQuestionIndex, _this.currentQuestionIndex) ||
                other.currentQuestionIndex == _this.currentQuestionIndex) &&
            (identical(other.score, _this.score) ||
                other.score == _this.score) &&
            (identical(other.xpEarned, _this.xpEarned) ||
                other.xpEarned == _this.xpEarned) &&
            (identical(other.secondsRemaining, _this.secondsRemaining) ||
                other.secondsRemaining == _this.secondsRemaining) &&
            (identical(other.isLoading, _this.isLoading) ||
                other.isLoading == _this.isLoading) &&
            (identical(other.isGameActive, _this.isGameActive) ||
                other.isGameActive == _this.isGameActive) &&
            (identical(other.lastSelectedAnswer, _this.lastSelectedAnswer) ||
                other.lastSelectedAnswer == _this.lastSelectedAnswer) &&
            (identical(other.lastAnsweredQuestionIndex,
                    _this.lastAnsweredQuestionIndex) ||
                other.lastAnsweredQuestionIndex ==
                    _this.lastAnsweredQuestionIndex) &&
            (identical(other.isLastAnswerCorrect, _this.isLastAnswerCorrect) ||
                other.isLastAnswerCorrect == _this.isLastAnswerCorrect) &&
            (identical(other.appException, _this.appException) ||
                other.appException == _this.appException) &&
            (identical(other.gameStartTime, _this.gameStartTime) ||
                other.gameStartTime == _this.gameStartTime) &&
            (identical(other.showResultDialog, _this.showResultDialog) ||
                other.showResultDialog == _this.showResultDialog) &&
            (identical(other.gameCategory, _this.gameCategory) ||
                other.gameCategory == _this.gameCategory) &&
            const DeepCollectionEquality()
                .equals(other.newlyEarnedTitles, _this.newlyEarnedTitles));
  }

  @override
  int get hashCode {
    final _this = this as GameState;
    return Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(_this.questions),
        _this.currentQuestionIndex,
        _this.score,
        _this.xpEarned,
        _this.secondsRemaining,
        _this.isLoading,
        _this.isGameActive,
        _this.lastSelectedAnswer,
        _this.lastAnsweredQuestionIndex,
        _this.isLastAnswerCorrect,
        _this.appException,
        _this.gameStartTime,
        _this.showResultDialog,
        _this.gameCategory,
        const DeepCollectionEquality().hash(_this.newlyEarnedTitles));
  }

  @override
  String toString() {
    final _this = this as GameState;
    return 'GameState(questions: ${_this.questions}, currentQuestionIndex: ${_this.currentQuestionIndex}, score: ${_this.score}, xpEarned: ${_this.xpEarned}, secondsRemaining: ${_this.secondsRemaining}, isLoading: ${_this.isLoading}, isGameActive: ${_this.isGameActive}, lastSelectedAnswer: ${_this.lastSelectedAnswer}, lastAnsweredQuestionIndex: ${_this.lastAnsweredQuestionIndex}, isLastAnswerCorrect: ${_this.isLastAnswerCorrect}, appException: ${_this.appException}, gameStartTime: ${_this.gameStartTime}, showResultDialog: ${_this.showResultDialog}, gameCategory: ${_this.gameCategory}, newlyEarnedTitles: ${_this.newlyEarnedTitles})';
  }
}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) =
      _$GameStateCopyWithImpl;
  @useResult
  $Res call(
      {List<MathQuestion> questions,
      int currentQuestionIndex,
      int score,
      int xpEarned,
      int secondsRemaining,
      bool isLoading,
      bool isGameActive,
      int? lastSelectedAnswer,
      int? lastAnsweredQuestionIndex,
      bool? isLastAnswerCorrect,
      AppException? appException,
      DateTime? gameStartTime,
      bool showResultDialog,
      GameCategory? gameCategory,
      List<TitleModel> newlyEarnedTitles});
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res> implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? currentQuestionIndex = null,
    Object? score = null,
    Object? xpEarned = null,
    Object? secondsRemaining = null,
    Object? isLoading = null,
    Object? isGameActive = null,
    Object? lastSelectedAnswer = freezed,
    Object? lastAnsweredQuestionIndex = freezed,
    Object? isLastAnswerCorrect = freezed,
    Object? appException = freezed,
    Object? gameStartTime = freezed,
    Object? showResultDialog = null,
    Object? gameCategory = freezed,
    Object? newlyEarnedTitles = null,
  }) {
    return _then(GameState(
      questions: null == questions
          ? _self.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<MathQuestion>,
      currentQuestionIndex: null == currentQuestionIndex
          ? _self.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _self.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      secondsRemaining: null == secondsRemaining
          ? _self.secondsRemaining
          : secondsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGameActive: null == isGameActive
          ? _self.isGameActive
          : isGameActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSelectedAnswer: freezed == lastSelectedAnswer
          ? _self.lastSelectedAnswer
          : lastSelectedAnswer // ignore: cast_nullable_to_non_nullable
              as int?,
      lastAnsweredQuestionIndex: freezed == lastAnsweredQuestionIndex
          ? _self.lastAnsweredQuestionIndex
          : lastAnsweredQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isLastAnswerCorrect: freezed == isLastAnswerCorrect
          ? _self.isLastAnswerCorrect
          : isLastAnswerCorrect // ignore: cast_nullable_to_non_nullable
              as bool?,
      appException: freezed == appException
          ? _self.appException
          : appException // ignore: cast_nullable_to_non_nullable
              as AppException?,
      gameStartTime: freezed == gameStartTime
          ? _self.gameStartTime
          : gameStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      showResultDialog: null == showResultDialog
          ? _self.showResultDialog
          : showResultDialog // ignore: cast_nullable_to_non_nullable
              as bool,
      gameCategory: freezed == gameCategory
          ? _self.gameCategory
          : gameCategory // ignore: cast_nullable_to_non_nullable
              as GameCategory?,
      newlyEarnedTitles: null == newlyEarnedTitles
          ? _self.newlyEarnedTitles
          : newlyEarnedTitles // ignore: cast_nullable_to_non_nullable
              as List<TitleModel>,
    ));
  }
}

/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GameState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GameState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GameState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<MathQuestion> questions,
            int currentQuestionIndex,
            int score,
            int xpEarned,
            int secondsRemaining,
            bool isLoading,
            bool isGameActive,
            int? lastSelectedAnswer,
            int? lastAnsweredQuestionIndex,
            bool? isLastAnswerCorrect,
            AppException? appException,
            DateTime? gameStartTime,
            bool showResultDialog,
            GameCategory? gameCategory,
            List<TitleModel> newlyEarnedTitles)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
            _that.questions,
            _that.currentQuestionIndex,
            _that.score,
            _that.xpEarned,
            _that.secondsRemaining,
            _that.isLoading,
            _that.isGameActive,
            _that.lastSelectedAnswer,
            _that.lastAnsweredQuestionIndex,
            _that.isLastAnswerCorrect,
            _that.appException,
            _that.gameStartTime,
            _that.showResultDialog,
            _that.gameCategory,
            _that.newlyEarnedTitles);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<MathQuestion> questions,
            int currentQuestionIndex,
            int score,
            int xpEarned,
            int secondsRemaining,
            bool isLoading,
            bool isGameActive,
            int? lastSelectedAnswer,
            int? lastAnsweredQuestionIndex,
            bool? isLastAnswerCorrect,
            AppException? appException,
            DateTime? gameStartTime,
            bool showResultDialog,
            GameCategory? gameCategory,
            List<TitleModel> newlyEarnedTitles)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState():
        return $default(
            _that.questions,
            _that.currentQuestionIndex,
            _that.score,
            _that.xpEarned,
            _that.secondsRemaining,
            _that.isLoading,
            _that.isGameActive,
            _that.lastSelectedAnswer,
            _that.lastAnsweredQuestionIndex,
            _that.isLastAnswerCorrect,
            _that.appException,
            _that.gameStartTime,
            _that.showResultDialog,
            _that.gameCategory,
            _that.newlyEarnedTitles);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<MathQuestion> questions,
            int currentQuestionIndex,
            int score,
            int xpEarned,
            int secondsRemaining,
            bool isLoading,
            bool isGameActive,
            int? lastSelectedAnswer,
            int? lastAnsweredQuestionIndex,
            bool? isLastAnswerCorrect,
            AppException? appException,
            DateTime? gameStartTime,
            bool showResultDialog,
            GameCategory? gameCategory,
            List<TitleModel> newlyEarnedTitles)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GameState() when $default != null:
        return $default(
            _that.questions,
            _that.currentQuestionIndex,
            _that.score,
            _that.xpEarned,
            _that.secondsRemaining,
            _that.isLoading,
            _that.isGameActive,
            _that.lastSelectedAnswer,
            _that.lastAnsweredQuestionIndex,
            _that.isLastAnswerCorrect,
            _that.appException,
            _that.gameStartTime,
            _that.showResultDialog,
            _that.gameCategory,
            _that.newlyEarnedTitles);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GameState extends GameState {
  const _GameState(
      {List<MathQuestion> questions = const [],
      this.currentQuestionIndex = 0,
      this.score = 0,
      this.xpEarned = 0,
      this.secondsRemaining = 0,
      this.isLoading = false,
      this.isGameActive = false,
      this.lastSelectedAnswer,
      this.lastAnsweredQuestionIndex,
      this.isLastAnswerCorrect,
      this.appException,
      this.gameStartTime,
      this.showResultDialog = false,
      this.gameCategory,
      List<TitleModel> newlyEarnedTitles = const []})
      : _questions = questions,
        _newlyEarnedTitles = newlyEarnedTitles,
        super._();

  final List<MathQuestion> _questions;
  @override
  @JsonKey()
  List<MathQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final int currentQuestionIndex;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey()
  final int xpEarned;
  @override
  @JsonKey()
  final int secondsRemaining;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isGameActive;
  @override
  final int? lastSelectedAnswer;
  @override
  final int? lastAnsweredQuestionIndex;
  @override
  final bool? isLastAnswerCorrect;
  @override
  final AppException? appException;
  @override
  final DateTime? gameStartTime;
  @override
  @JsonKey()
  final bool showResultDialog;
  @override
  final GameCategory? gameCategory;
  final List<TitleModel> _newlyEarnedTitles;
  @override
  @JsonKey()
  List<TitleModel> get newlyEarnedTitles {
    if (_newlyEarnedTitles is EqualUnmodifiableListView)
      return _newlyEarnedTitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newlyEarnedTitles);
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GameStateCopyWith<_GameState> get copyWith =>
      __$GameStateCopyWithImpl<_GameState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GameState &&
            const DeepCollectionEquality()
                .equals(other.questions, _questions) &&
            (identical(other.currentQuestionIndex, currentQuestionIndex) ||
                other.currentQuestionIndex == currentQuestionIndex) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.secondsRemaining, secondsRemaining) ||
                other.secondsRemaining == secondsRemaining) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isGameActive, isGameActive) ||
                other.isGameActive == isGameActive) &&
            (identical(other.lastSelectedAnswer, lastSelectedAnswer) ||
                other.lastSelectedAnswer == lastSelectedAnswer) &&
            (identical(other.lastAnsweredQuestionIndex,
                    lastAnsweredQuestionIndex) ||
                other.lastAnsweredQuestionIndex == lastAnsweredQuestionIndex) &&
            (identical(other.isLastAnswerCorrect, isLastAnswerCorrect) ||
                other.isLastAnswerCorrect == isLastAnswerCorrect) &&
            (identical(other.appException, appException) ||
                other.appException == appException) &&
            (identical(other.gameStartTime, gameStartTime) ||
                other.gameStartTime == gameStartTime) &&
            (identical(other.showResultDialog, showResultDialog) ||
                other.showResultDialog == showResultDialog) &&
            (identical(other.gameCategory, gameCategory) ||
                other.gameCategory == gameCategory) &&
            const DeepCollectionEquality()
                .equals(other.newlyEarnedTitles, _newlyEarnedTitles));
  }

  @override
  int get hashCode {
    return Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(_questions),
        currentQuestionIndex,
        score,
        xpEarned,
        secondsRemaining,
        isLoading,
        isGameActive,
        lastSelectedAnswer,
        lastAnsweredQuestionIndex,
        isLastAnswerCorrect,
        appException,
        gameStartTime,
        showResultDialog,
        gameCategory,
        const DeepCollectionEquality().hash(_newlyEarnedTitles));
  }

  @override
  String toString() {
    return 'GameState(questions: $questions, currentQuestionIndex: $currentQuestionIndex, score: $score, xpEarned: $xpEarned, secondsRemaining: $secondsRemaining, isLoading: $isLoading, isGameActive: $isGameActive, lastSelectedAnswer: $lastSelectedAnswer, lastAnsweredQuestionIndex: $lastAnsweredQuestionIndex, isLastAnswerCorrect: $isLastAnswerCorrect, appException: $appException, gameStartTime: $gameStartTime, showResultDialog: $showResultDialog, gameCategory: $gameCategory, newlyEarnedTitles: $newlyEarnedTitles)';
  }
}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(
          _GameState value, $Res Function(_GameState) _then) =
      __$GameStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<MathQuestion> questions,
      int currentQuestionIndex,
      int score,
      int xpEarned,
      int secondsRemaining,
      bool isLoading,
      bool isGameActive,
      int? lastSelectedAnswer,
      int? lastAnsweredQuestionIndex,
      bool? isLastAnswerCorrect,
      AppException? appException,
      DateTime? gameStartTime,
      bool showResultDialog,
      GameCategory? gameCategory,
      List<TitleModel> newlyEarnedTitles});
}

/// @nodoc
class __$GameStateCopyWithImpl<$Res> implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questions = null,
    Object? currentQuestionIndex = null,
    Object? score = null,
    Object? xpEarned = null,
    Object? secondsRemaining = null,
    Object? isLoading = null,
    Object? isGameActive = null,
    Object? lastSelectedAnswer = freezed,
    Object? lastAnsweredQuestionIndex = freezed,
    Object? isLastAnswerCorrect = freezed,
    Object? appException = freezed,
    Object? gameStartTime = freezed,
    Object? showResultDialog = null,
    Object? gameCategory = freezed,
    Object? newlyEarnedTitles = null,
  }) {
    return _then(_GameState(
      questions: null == questions
          ? _self._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<MathQuestion>,
      currentQuestionIndex: null == currentQuestionIndex
          ? _self.currentQuestionIndex
          : currentQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _self.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      secondsRemaining: null == secondsRemaining
          ? _self.secondsRemaining
          : secondsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isGameActive: null == isGameActive
          ? _self.isGameActive
          : isGameActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSelectedAnswer: freezed == lastSelectedAnswer
          ? _self.lastSelectedAnswer
          : lastSelectedAnswer // ignore: cast_nullable_to_non_nullable
              as int?,
      lastAnsweredQuestionIndex: freezed == lastAnsweredQuestionIndex
          ? _self.lastAnsweredQuestionIndex
          : lastAnsweredQuestionIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isLastAnswerCorrect: freezed == isLastAnswerCorrect
          ? _self.isLastAnswerCorrect
          : isLastAnswerCorrect // ignore: cast_nullable_to_non_nullable
              as bool?,
      appException: freezed == appException
          ? _self.appException
          : appException // ignore: cast_nullable_to_non_nullable
              as AppException?,
      gameStartTime: freezed == gameStartTime
          ? _self.gameStartTime
          : gameStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      showResultDialog: null == showResultDialog
          ? _self.showResultDialog
          : showResultDialog // ignore: cast_nullable_to_non_nullable
              as bool,
      gameCategory: freezed == gameCategory
          ? _self.gameCategory
          : gameCategory // ignore: cast_nullable_to_non_nullable
              as GameCategory?,
      newlyEarnedTitles: null == newlyEarnedTitles
          ? _self._newlyEarnedTitles
          : newlyEarnedTitles // ignore: cast_nullable_to_non_nullable
              as List<TitleModel>,
    ));
  }
}

// dart format on
