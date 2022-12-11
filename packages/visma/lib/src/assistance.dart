import 'package:logging/logging.dart';
import 'package:pumli/pumli.dart';

import 'visualizer/plantuml/plantuml_hacker.dart';

const appName = 'visma';
const vismaName = 'visma';
Logger getLogger(String name) => Logger('$vismaName.$name');

void initLogging() {
  // This shall be done 1st to allow Logger configuration for a hierarchy.
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;

  Logger(vismaName).level = Level.INFO;
  Logger('$PumliServer').level = Level.ALL;
  Logger('$Converter').level = Level.ALL;

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
