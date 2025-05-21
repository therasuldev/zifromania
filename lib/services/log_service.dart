// lib/services/log_service.dart
import 'package:logger/logger.dart' as lg;

/// Простая обёртка над `logger` — меняешь поставщика, а сигнатуры не ломаются.
class LogService {
  LogService({lg.Logger? logger}) : _logger = logger ?? lg.Logger(printer: lg.PrefixPrinter(lg.PrettyPrinter(colors: false)));

  final lg.Logger _logger;

  void d(String msg, [Object? err, StackTrace? st]) => _logger.d(msg, error: err, stackTrace: st);
  void i(String msg, [Object? err, StackTrace? st]) => _logger.i(msg, error: err, stackTrace: st);
  void w(String msg, [Object? err, StackTrace? st]) => _logger.w(msg, error: err, stackTrace: st);
  void e(String msg, [Object? err, StackTrace? st]) => _logger.e(msg, error: err, stackTrace: st);
}
