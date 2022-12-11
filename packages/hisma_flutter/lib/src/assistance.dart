import 'package:logging/logging.dart';

const libName = 'hisma_flutter';
Logger getLogger(String name) => Logger('$libName.$name');
