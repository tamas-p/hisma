/// Visma is visualizing Hisma state machines in the web browser.
///
/// This library was created for the command line tool called `visma` that
/// renders hierarchical state machines created with the `hisma` package to
/// interactive state machine diagrams. It gets state machine status updates
/// from its counterpart hisma monitor called `hisma_visual_monitor` and
/// renders them to interactive web pages with the help of the `pumli` package.
library visma;

export 'src/assistance.dart';
export 'src/visualizer/plantuml/plantuml_hacker.dart';
export 'src/visualizer/visual_monitor/server/visualization_server.dart';
