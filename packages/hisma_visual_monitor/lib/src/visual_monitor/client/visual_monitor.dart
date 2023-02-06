import 'dart:async';

import 'package:hisma/hisma.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../assistance.dart';
import '../../plantuml/plantuml_converter.dart';
import '../constants.dart';
import '../dto/c2s/registration_request_dto.dart';
import '../dto/c2s/upload_machine_dto.dart';
import '../dto/message.dart';
import '../dto/public.dart';
import '../dto/s2c/disconnect_request_dto.dart';
import '../dto/s2c/fire_message_dto.dart';
import '../dto/s2c/registration_response_dto.dart';
import '../dto/s2c/toggle_expand_dto.dart';

class VisualMonitor implements Monitor {
  VisualMonitor(
    this.stateMachine, {
    this.host = cHost,
    this.port = cPort,
  }) {
    _log.info('VisualMonitor created.');
  }
  static final _log = getLogger('$VisualMonitor');

  static String hostname = 'host';
  static String domain = 'domain';

  // TODO: implement naming override for state machine naming collisions.
  // static final smIds = <StateMachine<dynamic, dynamic, dynamic>, String>{};
  final StateMachine<dynamic, dynamic, dynamic> stateMachine;

  final String host;
  final int port;

  // We need this this to avoid processing notifyStateChange calls before
  // connection to visma is completed. Late is fine as notifyCreation (where
  // this variable is set) always preceding notifyStateChange.
  late Future<void> _connectCordCompleted;

  @override
  Future<void> notifyCreation() {
    _log.info('register stateMachine.myId=${stateMachine.name}');
    return _connectCordCompleted = _connectCord();
  }

  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _subscription;

  Future<void> _connectCord() async {
    while (true) {
      try {
        await _tryConnectCord();
      } catch (_) {
        await Future<void>.delayed(const Duration(seconds: retryDelay));
        continue;
      }
      break;
    }
  }

  /// Establishes cord between this state machine and the visualization server.
  /// This socket allows detecting disconnect between the two.
  Future<void> _tryConnectCord() async {
    _log.info('connectCord');
    final uriStr = 'ws://$host:$port$cord';
    _log.fine('${DateTime.now()} Starting connection to $uriStr');
    _ws = WebSocketChannel.connect(Uri.parse(uriStr));
    // This await is needed to get exceptions per adityabansalx's comment
    // at https://github.com/dart-lang/web_socket_channel/issues/38
    await _ws?.ready;
    _log.fine(
      '${DateTime.now()} Connection attempt completed: $_ws',
    );
    if (_ws == null) {
      _log.severe('Could not connect. Returning.');
      return Future.error('Could not connect.');
    }

    final completer = Completer<void>();
    _subscription = _ws?.stream.listen(
      (data) {
        _log.fine('message received: $data');
        _processMessage(completer: completer, data: data as String);
      },
      cancelOnError: false,
      onDone: () async {
        _log.info('onDone');
        if (completer.isCompleted) {
          _log.fine('completer is complete (cord was registered).');
          await _shutDownWebSocket();
          await Future<void>.delayed(const Duration(seconds: retryDelay));
          await _connectCord();
        } else {
          _log.fine('completer is NOT complete (cord was NOT registered).');
          completer.completeError('onDone');
        }
      },
      onError: (dynamic error) {
        _log.fine('onError: $error');
        // We do not do anything here on purpose as onDone is called anyway and
        // there we manage the websocket disconnect.
      },
    );

    _sendRegistration();
    return completer.future;
  }

  void _sendRegistration() {
    _log.info('Send registration...');
    final children = <String>[];
    stateMachine.states.forEach((stateId, state) {
      if (state is State) {
        for (final region in state.regions) {
          children.add(region.machine.name);
        }
      }
    });
    _log.fine('Children: $children');
    // final diagram = plantUml(stateMachine);
    final diagram = PlantUMLConverter(
      stateMachine: stateMachine, expandedItems: expandedItems,
      // theme: Theme.light(),
    ).diagram;

    final registrationRequestDTO = RegistrationRequestDTO(
      hostname: hostname,
      domain: domain,
      smId: stateMachine.name,
      diagram: diagram,
      children: children,
    );

    final myJson = registrationRequestDTO.toJson();
    _log.fine('JSON: $myJson');
    _ws?.sink.add(messageToJson(registrationRequestDTO));
  }

  Future<void> _shutDownWebSocket() async {
    _log.info('Cancelling subscription...');
    await _subscription?.cancel();
    _log.info('Closing sink');
    await _ws?.sink.close();
    _log.fine('Nulling websocket.');
    _ws = null;
    _log.fine('_shutDownWebSocket is Done.');
  }

  void _processMessage({
    required Completer<void> completer,
    required String data,
  }) {
    final m = messageFromJson(data);
    switch (m.runtimeType) {
      case RegistrationResponseDTO:
        // Asserting that this client has not been registered yet.
        assert(!completer.isCompleted);
        final response = m as RegistrationResponseDTO;
        if (response.successful) {
          _log.info('Registration successful.');
          completer.complete();
        } else {
          completer.completeError(
            'Registration FAILED: ${response.message}',
          );
        }
        break;
      case DisconnectRequestDTO:
        // Asserting that this client has been registered.
        assert(completer.isCompleted);
        final request = m as DisconnectRequestDTO;
        _log.info('Disconnect request from server:\n${request.message}');
        _shutDownWebSocket();
        break;
      case FireMessageDTO:
        // Asserting that this client has been registered.
        assert(completer.isCompleted);
        final fireMessageDTO = m as FireMessageDTO;
        _log.info('FireMessageDTO received: $fireMessageDTO');
        assert(
          stateMachine.events.isNotEmpty,
          'You must add "events" argument to StateMachine '
          '"${stateMachine.name}" constructor.',
        );
        final em = {for (var i in stateMachine.events) i.toString(): i};
        _log.fine('em=$em');
        final event = em[fireMessageDTO.event];
        assert(
          event != null,
          '"events" argument for StateMachine "${stateMachine.name}" '
          'does not include mapping for ${fireMessageDTO.event}',
        );
        stateMachine.fire(em[fireMessageDTO.event]);
        break;
      case ToggleExpandDTO:
        // Asserting that this client has been registered.
        assert(completer.isCompleted);
        final toggleExpandMessageDTO = m as ToggleExpandDTO;
        _log.info('Received: $toggleExpandMessageDTO');
        _log.fine('expandedItems=$expandedItems');
        if (toggleExpandMessageDTO.expand) {
          expandedItems.add(toggleExpandMessageDTO.id);
        } else {
          expandedItems.remove(toggleExpandMessageDTO.id);
        }
        _log.fine('expandedItems=$expandedItems');
        notifyStateChange();
        break;
      default:
        assert(false, 'Received unknown message of type: ${m.runtimeType}');
    }
  }

  @override
  Future<void> notifyStateChange() async {
    _log.info('Notified on state change.');
    await _connectCordCompleted;
    _log.info('Continue as _connectCordCompleted is completed.');
    // final diagram = plantUml(stateMachine);
    final diagram = PlantUMLConverter(
      stateMachine: stateMachine, expandedItems: expandedItems,
      // theme: Theme.light(),
    ).diagram;

    upload(diagram);
  }

  void upload(String diagram) {
    final children = <String>[];
    stateMachine.states.forEach((stateId, state) {
      if (state is State) {
        for (final region in state.regions) {
          children.add(region.machine.name);
        }
      }
    });
    _log.fine('Children: $children');

    _log.info('Uploading diagram through $_ws');
    _ws?.sink.add(
      messageToJson(
        UploadMachineDTO(
          hostname: hostname,
          domain: domain,
          smId: stateMachine.name,
          diagram: diagram,
          children: children,
        ),
      ),
    );
  }

  final expandedItems = <String>{};
}
