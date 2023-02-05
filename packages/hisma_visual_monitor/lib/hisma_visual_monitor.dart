/// Visual monitor for Hisma, a hierarchical state machine implementation.
///
/// Hisma defines a monitoring API: One can register monitor creator functions
/// and the monitors created by these will be invoked by Hisma when the state
/// machines are created or their active state changes.
/// This monitor is a visual monitor implementation for hisma. It transforms
/// and then sends state machine information to its counterpart, the `visma`
/// application. `visma` in turn renders these state machines to its
/// interactive web user interface.
library hisma_visual_monitor;

export 'src/constants.dart';
export 'src/plantuml/theme.dart';
export 'src/visual_monitor/client/visual_monitor.dart';
export 'src/visual_monitor/dto/c2s/registration_request_dto.dart';
export 'src/visual_monitor/dto/c2s/upload_machine_dto.dart';
export 'src/visual_monitor/dto/message.dart';
export 'src/visual_monitor/dto/public.dart';
export 'src/visual_monitor/dto/s2c/disconnect_request_dto.dart';
export 'src/visual_monitor/dto/s2c/fire_message_dto.dart';
export 'src/visual_monitor/dto/s2c/registration_response_dto.dart';
export 'src/visual_monitor/dto/s2c/toggle_expand_dto.dart';
