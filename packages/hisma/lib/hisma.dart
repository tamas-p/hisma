/// Hisma, a hierarchical state machine.
///
/// Hisma provides a declarative hierarchical state machine implementation that
/// loosely follows the [UML](https://www.omg.org/spec/UML/) State Machine
/// specification that is in turn based on
/// [Harel's statechart](https://en.wikipedia.org/wiki/State_diagram#Harel_statechart).
library hisma;

export 'src/action.dart';
export 'src/guard.dart';
export 'src/hisma_exception.dart';
export 'src/monitor.dart';
export 'src/region.dart';
export 'src/state.dart';
export 'src/state_machine.dart';
export 'src/transition.dart';
export 'src/trigger.dart';

// TODO: Export any libraries intended for clients of this package.
