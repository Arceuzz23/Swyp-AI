import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // Only show debug logs in debug mode
    level: kDebugMode ? Level.debug : Level.info,
  );

  static void debug(dynamic message) {
    // Replace print statements with this
    if (kDebugMode) {
      _logger.d('💡 DEBUG: $message');
    }
  }

  static void info(dynamic message) {
    _logger.i('ℹ️ INFO: $message');
  }

  static void warning(dynamic message) {
    _logger.w('⚠️ WARNING: $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ ERROR: $message', error: error, stackTrace: stackTrace);
  }

  static void verbose(dynamic message) {
    if (kDebugMode) {
      _logger.v('🔍 VERBOSE: $message');
    }
  }

  static void wtf(dynamic message) {
    _logger.wtf('💥 CRITICAL: $message');
  }

  // Helper method to log API calls
  static void logApi(
    String endpoint, {
    dynamic request,
    dynamic response,
    dynamic error,
  }) {
    if (error != null) {
      _logger.e(
        '🌐 API ERROR - $endpoint',
        error: error,
        stackTrace: StackTrace.current,
      );
      return;
    }

    _logger.i(
      '🌐 API Call - $endpoint\n'
      'Request: $request\n'
      'Response: $response',
    );
  }

  // Helper method to log navigation events
  static void logNavigation(String from, String to) {
    _logger.i('🔄 Navigation: $from → $to');
  }
}
