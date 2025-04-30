import 'dart:io' as io;

import 'package:logger/logger.dart';

class AppLogger extends LogPrinter {
  final prettyPrinter = PrettyPrinter(
    colors: io.stdout.supportsAnsiEscapes,
    methodCount: 0,
  );

  @override
  List<String> log(LogEvent event) {
    if (event.level == Level.error) {
      //use this method to log if analytics are implemented
    }

    return prettyPrinter.log(event);
  }
}
