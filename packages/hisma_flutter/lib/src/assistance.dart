import 'package:logging/logging.dart';

const libName = 'hisma_flutter';
Logger getLogger(String name) => Logger('$libName.$name');
String missingPresentationMsg(dynamic stateId, String name) =>
    'Presentation is not handled for $stateId.'
    ' Check mapping in your HismaRouterGenerator for machine $name';

String getKey(String machineName, dynamic stateId) => '$machineName@$stateId';

/// Indicates that the UI element connected to the state was already closed.
class UiClosed {
  UiClosed(this.arg);
  dynamic arg;
}
