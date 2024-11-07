import 'package:logging/logging.dart';

const libName = 'hisma_flutter';
Logger getLogger(String name) => Logger('$libName.$name');
String assertPresentationMsg(dynamic stateId, String name) =>
    'Presentation is not handled for $stateId.'
    ' Check mapping in your HismaRouterGenerator for machine $name';
