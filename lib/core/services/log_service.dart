import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart' as lg;

class LogService {
  final lg.Logger _logger;
  final printer = lg.PrefixPrinter(lg.PrettyPrinter());

  LogService({lg.Logger? logger}) : _logger = logger ?? lg.Logger(printer: lg.PrefixPrinter(lg.PrettyPrinter()));

  void d(String msg, [Object? err, StackTrace? st]) => _logger.d(msg, error: err, stackTrace: st);
  void i(String msg, [Object? err, StackTrace? st]) => _logger.i(msg, error: err, stackTrace: st);
  void w(String msg, [Object? err, StackTrace? st]) => _logger.w(msg, error: err, stackTrace: st);
  void e(String msg, [Object? err, StackTrace? st]) => _logger.e(msg, error: err, stackTrace: st);
}

// Global LogService Provider
final logServiceProvider = Provider<LogService>((ref) {
  return LogService();
});
