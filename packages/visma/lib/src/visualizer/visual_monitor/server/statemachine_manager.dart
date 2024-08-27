import 'dart:async';
import 'dart:io';

import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../../../assistance.dart';
import '../../plantuml/plantuml_hacker.dart';
import 'browser_notifier.dart';
import 'overview_manager.dart';
import 'server_utility.dart';

class StateMachineId {
  StateMachineId({
    required this.hostname,
    required this.domain,
    required this.smId,
  });

  final String hostname;
  final String domain;
  final String smId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StateMachineId &&
        other.hostname == hostname &&
        other.domain == domain &&
        other.smId == smId;
  }

  @override
  int get hashCode => hostname.hashCode ^ domain.hashCode ^ smId.hashCode;

  @override
  String toString() =>
      'StateMachineId(hostname: $hostname, domain: $domain, smId: $smId)';
}

class Registrar {
  Registrar({
    required this.ws,
    required this.onRemoval,
    required this.uploadMachine,
  });

  static final _log = getLogger('$Registrar');

  final WebSocket ws;
  StateMachineId? _uniqueSmId;
  final void Function(WebSocket ws, StateMachineId) onRemoval;
  final void Function({
    required StateMachineId uniqueSmId,
    required String diagram,
    required List<String> children,
  }) uploadMachine;

  Future<RegistrationRequestDTO?> register() {
    final completer = Completer<RegistrationRequestDTO?>();

    _log.fine('>>>> Register <<<<');

    ws.listen(
      (dynamic data) {
        _log.fine('Data received: $data');
        Message? m;
        try {
          m = messageFromJson(data as String);
        } on Exception catch (e) {
          _log.severe('Exception for: $data, ws=${ws.hashCode}');
          _log.severe(e);
          return;
        }
        switch (m.runtimeType) {
          case RegistrationRequestDTO:
            // Asserting that this client has not been registered yet.
            assert(!completer.isCompleted);
            final rd = m as RegistrationRequestDTO;
            _log.info('$RegistrationRequestDTO received. smId:${m.smId}');
            // Set machine id to be used when cord (ws) is disconnected.
            _uniqueSmId = StateMachineId(
              hostname: rd.hostname,
              domain: rd.domain,
              smId: rd.smId,
            );
            completer.complete(rd);
            break;
          case UploadMachineDTO:
            _log.fine('$UploadMachineDTO received');
            // Asserting that this client has been registered.
            assert(completer.isCompleted);
            final uploadMachineDTO = m as UploadMachineDTO;
            final uniqueSmId = StateMachineId(
              hostname: m.hostname,
              domain: m.domain,
              smId: m.smId,
            );

            uploadMachine(
              uniqueSmId: uniqueSmId,
              diagram: uploadMachineDTO.diagram,
              children: uploadMachineDTO.children,
            );
            break;
          default:
            assert(false, 'Received unknown message of type: ${m.runtimeType}');
        }
      },
      cancelOnError: true,
      onDone: () {
        _log.info('Cord DONE, SM disconnected.');
        if (_uniqueSmId != null) onRemoval(ws, _uniqueSmId!);
        if (!completer.isCompleted) completer.complete(null);
      },
      onError: (Object error) {
        _log.warning('Cord ERROR: $error');
        if (_uniqueSmId != null) onRemoval(ws, _uniqueSmId!);
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    return completer.future;
  }
}

class StateMachineManager {
  StateMachineManager(this.converter);

  static final _log = getLogger('$StateMachineId');

  final Converter converter;
  final _machines = <StateMachineId, MachineRepresentation>{};
  final _overviewManager = OverviewManager();

  Future<void> addClient(WebSocket ws) async {
    final registrar = Registrar(
      ws: ws,
      onRemoval: _remove,
      uploadMachine: _uploadMachine,
    );
    final rd = await registrar.register();
    if (rd != null) {
      try {
        _register(registrationData: rd, webSocket: ws);
        ws.add(messageToJson(RegistrationResponseDTO(successful: true)));
      } on Exception catch (err) {
        ws.add(
          messageToJson(
            RegistrationResponseDTO(
              successful: false,
              message: err.toString(),
            ),
          ),
        );
        await ws.close();
      }
    } else {
      _log.fine('Could not register: $rd');
      await ws.close();
    }
  }

  Future<String> renderOverview() async {
    return converter.convertToSvg(_overviewManager.render());
  }

  StateMachineId _pathToSMid(String uniqueSmIdPath) {
    _log.fine('uniqueSmIdPath=$uniqueSmIdPath');
    final segments = uniqueSmIdPath.split('/');
    _log.fine('segments=$segments');
    assert(segments.length == 3, 'Path must be in host/domain/smId format.');
    final decodedSegments =
        segments.map((segment) => Uri.decodeComponent(segment)).toList();
    final hostname = decodedSegments[0];
    final domain = decodedSegments[1];
    final smId = decodedSegments[2];

    return StateMachineId(hostname: hostname, domain: domain, smId: smId);
  }

  Future<String> renderMachine(String uniqueSmIdPath) async {
    final machine = _machines[_pathToSMid(uniqueSmIdPath)];
    final diagram = machine?.machineData?.diagram;
    _log.fine('UNIQUE_PATH=$uniqueSmIdPath');
    final decoded = Uri.decodeFull(uniqueSmIdPath);
    final svg = diagram != null
        ? await converter.convertToSvg(diagram)
        : getSvgText(
            'Requested machine is not available in Visma.',
            description: 'Machine id: $decoded',
          );
    return svg;
  }

  void _uploadMachine({
    required StateMachineId uniqueSmId,
    required String diagram,
    required List<String> children,
  }) {
    final machine = _machines[uniqueSmId];
    final machineData = machine?.machineData;
    assert(machine != null);
    assert(machineData != null);

    if (machine != null && machineData != null) {
      _log.fine('Adding machine <<<<<<<<<<<<<<<<');
      machineData.diagram = diagram;
      machine.notifyViewers();
    }

    // This was added to be able update overview if children of a mutable
    // StateMachine have changed.
    _overviewManager.add(
      uniqueSmId: uniqueSmId,
      children: children.toSet(),
    );
  }

  void addMachineListener({
    required String uniqueSmIdPath,
    required WebSocket websocket,
  }) {
    final uniqueSmId = _pathToSMid(uniqueSmIdPath);
    var machine = _machines[uniqueSmId];
    if (machine == null) {
      _log.warning('Could not find machine by smId="$uniqueSmIdPath".');
      // Our state machine disappeared from _machines, let's get be subscribed
      // to it in order to be notified when it comes back. We do so by adding
      // the machine to _machines without a diagram...
      machine = MachineRepresentation();
      _machines[uniqueSmId] = machine;
    }

    // ...and register for the notifications...
    machine.addListener(
      listener: websocket,
      // ...but also be ready if it never comes back and all subscribed
      // browser sessions are closed then this cleanup will remove that
      // machine without diagram (machineData) and without any subscribers
      // to avoid a memory leek.
      cleanup: () {
        if (machine?.machineData == null) {
          _machines.remove(uniqueSmId);
        }
      },
      processMessage: (message) {
        late String machineName;
        switch (message.runtimeType) {
          case FireMessageDTO:
            machineName = (message as FireMessageDTO).machine;
            break;
          case ToggleExpandDTO:
            machineName = uniqueSmId.smId;
            break;
          default:
            assert(
              false,
              'Received unknown message of type: ${message.runtimeType}',
            );
        }

        final mid = StateMachineId(
          hostname: uniqueSmId.hostname,
          domain: uniqueSmId.domain,
          smId: machineName,
        );
        _log.fine('mid=$mid');
        _log.fine(
          '''
          >${_machines[mid]?.machineData?.clientWebSocket}
          SUBSCRIPTION data received: $message
          ''',
        );
        final ws = _machines[mid]?.machineData?.clientWebSocket;
        if (ws == null) {
          _log.warning('No websocket for machine $mid');
          return;
        }

        final messageJson = messageToJson(message);
        _log.fine(
          'Sending message to client (ws=${ws.hashCode}): $messageJson',
        );
        ws.add(messageJson);
      },
    );
  }

  void addOverviewListener({
    required WebSocket websocket,
  }) {
    _overviewManager.addListener(listener: websocket);
  }

  void _register({
    required RegistrationRequestDTO registrationData,
    required WebSocket webSocket,
  }) {
    _log.fine(registrationData);
    _log.fine(registrationData.hostname);
    _log.fine(registrationData.domain);
    _log.fine(registrationData.smId);
    _log.fine(registrationData.diagram);

    final uniqueSmId = StateMachineId(
      hostname: registrationData.hostname,
      domain: registrationData.domain,
      smId: registrationData.smId,
    );

    // It's only a problem if machine is found in our registry if the
    // found MachineRegistry contains the uploaded diagram and the
    // corresponding websocket in machineData. Otherwise this item is kept
    // here only to allow machine web pages to listen to be notified when
    // the machine is actually registering.

    final machine = _machines[uniqueSmId];
    if (machine != null && machine.machineData != null) {
      // hot-reload-fix: Addressing web hot-reload weakness of not being able
      // to cleanup established websockets from the client.
      // See https://github.com/flutter/flutter/issues/69949
      // Originally we rejected registration request for a machine that was
      // already registered, expecting that during restarts the websocket
      // connections are closed. As it does not happens during web hot-reload
      // design had to change to accept registration for the same machine and
      // asking disconnecting the old one.
      _log.warning(
        'As machine is already registered, '
        'sending disconnect request for $uniqueSmId',
      );

      final message = '''
Registration request arrived for this machine: $uniqueSmId.
Please disconnect this old cord as I am registering that new one.''';
      machine.machineData?.clientWebSocket.add(
        messageToJson(
          DisconnectRequestDTO(message: message),
        ),
      );

      // machine.machineData?.clientWebSocket.close();

      // _machines.remove(uniqueSmId);
      // throw Exception(message);
    }

    _add(
      stateMachineId: uniqueSmId,
      diagram: registrationData.diagram,
      webSocket: webSocket,
    );

    _overviewManager.add(
      uniqueSmId: uniqueSmId,
      children: registrationData.children.toSet(),
    );
  }

  void _add({
    required StateMachineId stateMachineId,
    required String diagram,
    required WebSocket webSocket,
  }) {
    final machineData = MachineData(
      diagram: diagram,
      clientWebSocket: webSocket,
    );
    var machine = _machines[stateMachineId];
    if (machine == null) {
      machine = MachineRepresentation(machineData);
      _machines[stateMachineId] = machine;
    } else {
      machine.machineData = machineData;
    }

    machine.notifyViewers();
  }

  void _remove(WebSocket ws, StateMachineId uniqueSmId) {
    _log.fine('Removing smId:"$uniqueSmId"');
    final machine = _machines[uniqueSmId];
    // We only remove the machine if the websocket closing is the same
    // as the websocket registered for this machine. It is needed to avoid
    // removal of new machine registration when disconnecting the old one.
    // It happens during hot-reload.
    // See: search hot-reload-fix in this file.
    if (machine != null && ws == machine.machineData?.clientWebSocket) {
      if (machine.thereIsSubscriber()) {
        // If there are subscribers we only null/delete the data to
        // save subscriptions, letting them notified if those state
        // machines are coming back.
        machine.machineData = null;
      } else {
        _machines.remove(uniqueSmId);
      }
      machine.notifyViewers();
      _overviewManager.remove(uniqueSmId);
    }
  }
}

class MachineData {
  MachineData({
    required this.diagram,
    required this.clientWebSocket,
  });

  String diagram;
  WebSocket clientWebSocket;
}

class MachineRepresentation with BrowserNotifier {
  MachineRepresentation([this.machineData]);

  MachineData? machineData;
}
