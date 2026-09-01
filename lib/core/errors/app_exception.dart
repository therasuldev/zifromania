import 'package:equatable/equatable.dart';

/// Base Exception class used throughout the project.
abstract class AppException extends Equatable implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, error, stackTrace];

  @override
  String toString() => '$runtimeType: $message';
}
