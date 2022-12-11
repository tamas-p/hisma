/// Simple monitor implementation for the Hisma package.
///
/// Hisma defines a monitoring API: One can register monitor creator functions
/// and the monitors created by these will be invoked by Hisma when the state
/// machines are created or their active state changes.
/// This monitor is a simple monitor implementation for Hisma. It logs these
/// events formatted to the console.
library hisma_console_monitor;

export 'src/active_state_visualizer.dart';
export 'src/console_monitor.dart';
