class OperationCanceledException implements Exception {
  final String message;
  const OperationCanceledException([this.message = 'Operation cancelled.']);

  @override
  String toString() => message;
}

class CancelToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const OperationCanceledException();
    }
  }
}
