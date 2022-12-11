import 'package:logging/logging.dart';

const hismaName = 'hisma';
Logger getLogger(String name) => Logger('$hismaName.$name');

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;

  Logger.root.level = Level.OFF;
  Logger(hismaName).level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: '
      '${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
}
