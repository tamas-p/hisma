import 'dart:convert';

import 'package:hisma/hisma.dart';

import '../assistance.dart';
import '../visual_monitor/client/visual_monitor.dart';
import '../visual_monitor/dto/message.dart';
import '../visual_monitor/dto/public.dart';
import '../visual_monitor/dto/s2c/fire_message_dto.dart';
import '../visual_monitor/dto/s2c/toggle_expand_dto.dart';
import 'theme.dart';

const _up = '(^)';
const _open = '(+)';
const _close = '(-)';

class PlantUMLConverter {
  PlantUMLConverter({
    required this.stateMachine,
    required this.expandedItems,
    Theme? theme,
  }) : _theme = theme ?? Theme.dark() {
    expandedItems.add(_getMachineName(stateMachine.name));
    _log.info('PlantUMLConverter expandedItems=$expandedItems');
  }

  static final _log = getLogger('$PlantUMLConverter');

  // Includes all state identifiers where the corresponding state shall be
  // rendered with its regions (if any defined in that state).
  // If a state identifier is not included but it has regions defined then
  // only the open '(+)' sign shown indicating that this state has regions.
  final Set<String> expandedItems;

  Machine<dynamic, dynamic, dynamic> stateMachine;
  final Theme _theme;

  final _sb = StringBuffer('@startuml Machine\n');

  String get diagram {
    _writePrefix();
    _sb.write(
      MachineConverter(
        machine: stateMachine,
        isRoot: true,
        expandedItems: expandedItems,
        theme: _theme,
      ).diagram,
    );
    _writePostfix();
    return _sb.toString();
  }

  void _writePrefix() {
    // Test for smetana (GraphViz dot transited to Java and into plantuml.jar)
    // Initial result are worse than original GraphViz dot.
    // _sb.writeln('!pragma layout smetana');

    _sb.write(
      '''
skinparam {
  shadowing false
  backgroundColor ${_theme.backgroundColor}
  ArrowColor ${_theme.passiveTransitionColor}
  ArrowFontColor ${_theme.lineColor}
  HyperLinkColor ${_theme.activeTransitionColor}
  HyperlinkUnderline false

  StateBackgroundColor ${_theme.passiveStateColor}
  StateFontColor ${_theme.lineColor}
  StateAttributeFontColor ${_theme.lineColor}
  StateBorderColor ${_theme.lineColor}
  StateStartColor ${_theme.lineColor}
  StateEndColor ${_theme.lineColor}
}    

set separator none
hide empty description
''',
    );
  }

  void _writePostfix() {
    _sb.write('@enduml');
  }
}

class MachineConverter {
  MachineConverter({
    required this.machine,
    this.isRoot = false,
    required this.expandedItems,
    required this.theme,
    this.currentTab = '',
    this.prefix = 'prefix',
  }) : _linkPrefix = getLinkPrefix(
          VisualMonitor.hostname,
          VisualMonitor.domain,
        ) {
    _convert();
  }

  final String _linkPrefix;
  final bool isRoot;

  Theme theme;
  Machine<dynamic, dynamic, dynamic> machine;

  /// Contains all state identifiers whose regions has to be shown.
  final Set<String> expandedItems;

  final String currentTab;
  final String prefix;

  static const String _tab = '    ';
  final _sb = StringBuffer();
  final _exitsSb = StringBuffer();
  final _exits = <ExitInfo>[];

  String get diagram => _sb.toString();

  // Writes without tabulation.
  void _write(String str) => _sb.write(str);
  void _writeln([String? str]) => _write('${str ?? ''}\n');

  // Writes with tabulation received in constructor.
  // Primary writes, used for a state machine record.
  void _pWrite(String str) => _write('$currentTab$str');
  void _pWriteln(String str) => _pWrite('$str\n');

  // Writes with an extra tab added to the tabulation received in constructor.
  // Content writes, used for states and transitions inside the state machine.
  void _cWrite(String str) => _pWrite('$_tab$str');
  void _cWriteln(String str) => _cWrite('$str\n');

  // Content plus writes, used for connectors.
  void _cpWrite(String str) => _cWrite('$_tab$str');
  void _cpWriteln(String str) => _cpWrite('$str\n');

  void _convert() {
    final machineStyle = machine.activeStateId == null
        ? theme.machineStyleStopped
        : theme.machineStyleStarted;
    // _writeln();

    final mn = _getMachineName(machine.name);
    var goUp = '';
    var expandOnClick = '';
    if (isRoot) {
      final parentName = machine.parent?.name;
      if (parentName != null) {
        final uriEncodedParentName = Uri.encodeComponent(parentName);
        goUp = '[[$_linkPrefix$uriEncodedParentName $_up]] ';
      } else {
        goUp = '[[/ $_up]] ';
      }
    } else {
      if (_shallWeShowStateMachine(mn)) {
        final tm = ToggleExpandDTO(id: mn, expand: false);
        expandOnClick = _getOnClickHack(message: tm, label: ' $_close');
      } else {
        final tm = ToggleExpandDTO(id: mn, expand: true);
        expandOnClick = _getOnClickHack(message: tm, label: ' $_open');
      }
    }

    final uriEncodedMachineName = Uri.encodeComponent(machine.name);
    _pWrite(
      'state "$goUp'
      '[[$_linkPrefix$uriEncodedMachineName ${machine.name}]]'
      '$expandOnClick"',
    );
    _pWriteln(' as $prefix $machineStyle {');
    _writeEntryPoints();
    _writeExitPoints();
    if (_shallWeShowStateMachine(mn)) _iterateStates();
    _pWriteln('}');
  }

  void _writeEntryPoints() {
    _cWriteln("'EntryPoints");
    machine.states.forEach((stateId, state) {
      if (state is BaseEntryPoint) {
        _writeEntryPoint(stateId);
      }
    });
  }

  void _writeExitPoints() {
    // Writing ExitPoints
    _writeln();
    _cWriteln("'ExitPoints");
    machine.states.forEach((stateId, state) {
      if (state is ExitPoint) _writeExitPoint(stateId, state);
    });
  }

  void _iterateStates() {
    _cWriteln("'History");
    if (machine.history != null) {
      _writeDefaultHistoryTransition(machine.history!);
    }

    _cWriteln("'States");
    machine.states.forEach((stateId, state) {
      if (state is State) _writeState(stateId, state);
      _writeln();
    });

    _cWriteln("'FinalStates");
    machine.states.forEach((stateId, state) {
      if (state is FinalState) _writeStateWithStereotype(stateId, 'end');
      _writeln();
    });

    _cWriteln("'EntryPoint transitions");
    machine.states.forEach((stateId, state) {
      if (state is EntryPoint) {
        _writeEntryPointInternalTransitions(stateId, state);
      } else if (state is HistoryEntryPoint) {
        _writeHistoryEntryPoint(stateId, state);
      }
    });

    // Write out the transitions from exit-points.
    if (_exitsSb.isNotEmpty) {
      LineSplitter.split(_exitsSb.toString()).forEach((line) {
        _cWriteln(line);
      });
      _writeln();
    }

    // Writing transitions. It must come at the end as PlantUML needs all
    // states defined before we define transitions between them.
    _writeln();
    _cWriteln("'Transitions");
    final entryPoints = <String>{};
    machine.states.forEach((stateId, state) {
      if (state is State) _writeTransitions(stateId, state, entryPoints);
    });
  }

  String _getOnClickHack({required Message message, required String label}) {
    final sb = StringBuffer();
    sb.write('<font:$addOnClickHereMagic');
    sb.write(messageUriEncodedToJson(message: message));
    sb.write('><color:${theme.activeTransitionColor}>$label</color>');
    sb.write('</font>');
    return sb.toString();
  }

  bool _shallWeShowRegions(String prefixedStateId) {
    return expandedItems.contains(prefixedStateId);
  }

  bool _shallWeShowStateMachine(String stateMachineId) {
    return expandedItems.contains(stateMachineId);
  }

  void _writeState(
    dynamic stateId,
    State<dynamic, dynamic, dynamic> state,
  ) {
    final stateIdPrefixed = _getPrefixed(prefix: prefix, id: '$stateId');

    final color = machine.activeStateId == stateId
        ? theme.activeStateColor
        : theme.passiveStateColor;

    final stateName = _getStateName(stateIdPrefixed);
    late String expandOnClick;
    if (state.regions.isEmpty) {
      expandOnClick = '';
    } else {
      if (_shallWeShowRegions(stateName)) {
        final tm = ToggleExpandDTO(id: stateName, expand: false);
        expandOnClick = _getOnClickHack(message: tm, label: ' $_close');
      } else {
        final tm = ToggleExpandDTO(id: stateName, expand: true);
        expandOnClick = _getOnClickHack(message: tm, label: ' $_open');
      }
    }

    _cWrite('state "$stateId$expandOnClick" as $stateIdPrefixed #$color');

    final regions = state.regions;
    if (_shallWeShowRegions(stateName) && regions.isNotEmpty) {
      _writeln(' {');
      _iterateRegions(stateId, stateIdPrefixed, state, regions);
      _cWrite('}');
    }
    _writeln();

    _writeStateActions(stateIdPrefixed, state);
    _writeInternalTransitions(stateIdPrefixed, stateId, state);

    if (stateId == machine.initialStateId) {
      _cWriteln('[*] -$_transitionPrefix> $prefix.$stateId');
    }
  }

  void _writeStateActions(
    String stateIdPrefixed,
    State<dynamic, dynamic, dynamic> state,
  ) {
    _cWrite('$stateIdPrefixed : ');
    final onEntry = state.onEntry;
    if (onEntry != null) _write('entry / ${onEntry.description}');

    // final doActivity = state.doActivity;
    // if (doActivity != null) _write('\\ndo / ${doActivity.description}');

    final onExit = state.onExit;
    if (onExit != null) _write('\\nexit / ${onExit.description}');
    _writeln();
  }

  void _writeInternalTransitions(
    String stateIdPrefixed,
    dynamic stateId,
    State<dynamic, dynamic, dynamic> state,
  ) {
    state.etm.forEach((eventId, transitionIds) {
      for (final transitionId in transitionIds) {
        final transition = machine.transitions[transitionId];
        if (transition is InternalTransition) {
          _cWrite('$stateIdPrefixed : ');
          _write(
            _getInternalTransitionLabel(
              stateId: stateId,
              transitionId: transitionId,
              transition: transition,
              eventId: eventId,
            ),
          );
          _writeln();
        }
      }
    });
  }

  String _getInternalTransitionLabel({
    required dynamic stateId,
    required dynamic transitionId,
    required InternalTransition<dynamic> transition,
    required dynamic eventId,
  }) {
    final sb = StringBuffer();
    final active = stateId == machine.activeStateId;

    assert(eventId != null);
    if (active) {
      final fireMessageDTO = FireMessageDTO(
        event: '$eventId',
        machine: machine.name,
      );
      sb.write(_getOnClickHack(message: fireMessageDTO, label: '$eventId'));
    } else {
      sb.write('$eventId');
    }

    sb.write(' / ');
    sb.write('$transitionId = ');

    if (transition.minInterval != null) {
      sb.write(' <${transition.minInterval}>');
    }

    final guard = transition.guard;
    if (guard != null) sb.write(' [${guard.description}]');

    if (transition.priority != 0) {
      sb.write(' (${transition.priority})');
    }

    final onAction = transition.onAction;
    if (onAction != null) sb.write(' ${onAction.description}');

    final onError = transition.onSkip;
    if (onError != null) sb.write(' || ${onError.description}');

    return sb.toString();
  }

  void _iterateRegions(
    dynamic stateId,
    String statePrefix,
    BaseState<dynamic, dynamic, dynamic> state,
    List<Region<dynamic, dynamic, dynamic, dynamic>> regions,
  ) {
    for (var i = 0; i < regions.length; i++) {
      final region = regions[i];
      final regionName = '$statePrefix.R$i';
      _writeConnectors(
        prefix: statePrefix,
        region: region,
        regionNumber: i,
      );
      final mc = MachineConverter(
        machine: region.machine,
        expandedItems: expandedItems,
        theme: theme,
        prefix: regionName,
        currentTab: '$currentTab$_tab$_tab',
      );
      _writeln(mc.diagram);
      // _prepareExits(stateId, state, statePrefix, region, i, mc._exits);
    }

    // Write exitConnectors for this state.
    final exitConnectors = <String>{};
    for (final region in regions) {
      region.exitConnectors?.forEach((exitPointId, eventId) {
        exitConnectors.add(
          'state " " as ${_getExitConnectorId(
            statePrefix: statePrefix,
            eventId: eventId,
          )} <<outputPin>> #${theme.lineColor}',
        );
      });
    }
    _cpWriteln("'ExitConnectors");
    for (final exitConnector in exitConnectors) {
      _cpWriteln(exitConnector);
    }

    _cpWriteln("'Connections from ExitPoints to ExitConnectors");
    // Write connections from exitPoints to exitConnectors
    for (var i = 0; i < regions.length; i++) {
      // for (final region in regions) {
      final region = regions[i];
      region.machine.states.forEach((subStateId, subState) {
        if (subState is ExitPoint) {
          final eventId = region.exitConnectors?[subStateId];
          if (eventId != null) {
            _cpWriteln(
              '$statePrefix.R$i.$subStateId -[${theme.connectorStyle}]-> '
              '${_getExitConnectorId(
                statePrefix: statePrefix,
                eventId: eventId,
              )}',
            );
          }
        }
      });
    }

    // Write transitions from exitConnectors to transition target states.
  }

  void _writeConnectors({
    required String prefix,
    required Region<dynamic, dynamic, dynamic, dynamic> region,
    required int regionNumber,
  }) {
    final entryConnectors = <String>{};
    region.entryConnectors?.forEach((trigger, entryPointId) {
      entryConnectors.add(
        'state " " as ${_getEntryConnectorId(
          statePrefix: prefix,
          trigger: trigger,
        )} <<inputPin>>',
      );
    });
    _writeln();
    _cpWriteln("'Entry connectors");
    for (final entryConnector in entryConnectors) {
      _cpWriteln(entryConnector);
    }

/*
    final exitConnectors = <String>{};
    region.exitConnectors?.forEach((exitPointId, eventId) {
      exitConnectors.add('state " " as ${_getExitConnectorId(
        statePrefix: prefix,
        exitPointId: exitPointId,
        eventId: eventId,
      )} <<outputPin>> #${theme.lineColor}');
    });
    _cpWriteln("'Exit connectors");
    for (final exitConnector in exitConnectors) {
      _cpWriteln(exitConnector);
    }
    */
    _writeln();
  }

  String _getExitConnectorId({
    required String statePrefix,
    required dynamic eventId,
  }) =>
      'EXIT_CONNECTOR.$statePrefix.$eventId';
  // 'EXIT_CONNECTOR.$statePrefix.R$regionNumber.$exitPointId.$eventId';

  String _getEntryConnectorId({
    required String statePrefix,
    required Trigger<dynamic, dynamic, dynamic> trigger,
  }) =>
      'ENTRY_CONNECTOR.$statePrefix.${trigger.source}.'
      '${trigger.event}.${trigger.transition}';
  // 'ENTRY_CONNECTOR.$statePrefix.R$regionNumber.${trigger.source}.'
  // '${trigger.event}.${trigger.transition}';

/*
  void _prepareExits(
    dynamic stateId,
    BaseState<dynamic, dynamic, dynamic> state,
    String statePrefix,
    Region<dynamic, dynamic, dynamic, dynamic> region,
    int regionNumber,
    List<ExitInfo> exits,
  ) {
    _exitsSb.writeln("'Exits from region ${region.machine.name}");
    for (final exit in exits) {
      final eventId = region.exitConnectors?[exit.stateId];
      if (eventId == null) continue;

      final prefixedExitStateId = '$statePrefix.R$regionNumber.${exit.stateId}';
      final exitConnectorId = _getExitConnectorId(
        statePrefix: statePrefix,
        eventId: eventId,
      );
      // First we write connection to the exit connector.
      _cWriteln(
        '$prefixedExitStateId -[${theme.connectorStyle}]-> $exitConnectorId',
      );

      final trIds = <TransitionWithId>{};
      // Then we write transition to the target state from the exit connector.
      final transitionIds = state.etm?[eventId];
      transitionIds?.forEach((transitionId) {
        final transition = machine.transitions[transitionId];
        if (transition != null) {
          trIds.add(TransitionWithId(id: transitionId, transition: transition));
        }
      });

      for (final transitionWithId in trIds) {
        _exitsSb.writeln(
          _getTransition(
            stateId: stateId,
            source: exitConnectorId,
            target: '$prefix.${transitionWithId.transition.to}',
            transitionId: transitionWithId.id,
            transition: transitionWithId.transition,
            event: eventId,
          ),
        );
      }
    }
  }
*/

  /// Introduced to alternate between --> and ---> transitions to
  /// workaround PlantUML issue. See for more details:
  /// https://github.com/plantuml/plantuml/issues/1005
  ///
  // For the moment (2022.09.27) this is turned off.
  final String _transitionPrefix = '-';
  String _getTransitionPrefix() {
    return _transitionPrefix;
    // return _transitionPrefix = _transitionPrefix == '' ? '-' : '';
  }

  String _getTransition({
    required dynamic stateId,
    required String source,
    required String target,
    required dynamic transitionId,
    required Transition<dynamic> transition,
    required dynamic event,
  }) {
    final sb = StringBuffer();
    final active = stateId == machine.activeStateId;
    final color =
        active ? theme.activeTransitionColor : theme.passiveTransitionColor;
    sb.write('$source -[#$color]${_getTransitionPrefix()}> $target : ');

    // If event is null we are handling transitions from an EntryPoint.
    if (event != null) {
      if (active) {
        final fireMessageDTO = FireMessageDTO(
          event: '$event',
          machine: machine.name,
        );
        sb.write(_getOnClickHack(message: fireMessageDTO, label: '$event'));
      } else {
        sb.write(event);
      }
    }

    sb.write('\\n$transitionId');

    if (transition.minInterval != null) {
      sb.write('\\n<${transition.minInterval}>');
    }
    final guard = transition.guard;
    if (guard != null) sb.write('\\n[${guard.description}]');

    if (transition.priority != 0) {
      sb.write('\\n(${transition.priority})');
    }

    final onAction = transition.onAction;
    if (onAction != null) sb.write('\\n${onAction.description}');

    final onError = transition.onSkip;
    if (onError != null) sb.write(' || ${onError.description}');

    return sb.toString();
  }

  void _writeTransitions(
    dynamic stateId,
    State<dynamic, dynamic, dynamic> state,
    Set<String> entryPoints,
  ) {
    state.etm.forEach((eventId, transitionIds) {
      for (final transitionId in transitionIds) {
        final transition = machine.transitions[transitionId];
        assert(
          transition != null,
          "In machine named '${machine.name}' at state '$stateId' for "
          "event '$eventId' the transition referenced by '$transitionId' is "
          'not defined.',
        );
        if (transition == null) continue;
        assert(
          transition is Transition || transition is InternalTransition,
          "In machine named '${machine.name}' at state '$stateId' for "
          "event '$eventId' the transition referenced by '$transitionId' "
          'is neither Transition nor InternalTransition: $transition',
        );

        if (transition is Transition<dynamic>) {
          _writeExternalTransitions(
            stateId: stateId,
            state: state,
            eventId: eventId,
            transitionId: transitionId,
            transition: transition,
            entryPoints: entryPoints,
          );
        }
      }
    });
  }

  void _writeExternalTransitions({
    required dynamic stateId,
    required State<dynamic, dynamic, dynamic> state,
    required dynamic eventId,
    required dynamic transitionId,
    required Transition<dynamic> transition,
    required Set<String> entryPoints,
  }) {
    var handled = false;

    // ---------------------------------------------------------------------
    // EntryPoint
    // ---------------------------------------------------------------------

    // Only try connecting transition to entry points (through entry
    // connectors) of regions of the target state if that target state
    // id is in expandedItems.
    final prefixedToStateId =
        _getPrefixed(prefix: prefix, id: '${transition.to}');
    if (_shallWeShowRegions(_getStateName(prefixedToStateId))) {
      final toState = machine.stateAt(transition.to);

      final trigger = Trigger(
        source: stateId,
        event: eventId,
        transition: transitionId,
      );

      final connectorIds = <String>{};
      for (var i = 0; i < (toState?.regions.length ?? 0); i++) {
        final region = toState?.regions[i];
        // final toEntryPointId = region?.entryConnectors?[trigger];
        final selected = getEntryPointId(region?.entryConnectors, trigger);
        final toEntryPointId = selected?.value;
        final connectorTrigger = selected?.key;
        if (toEntryPointId != null && connectorTrigger != null) {
          handled = true;
          final connectorId = _getEntryConnectorId(
            statePrefix: '$prefix.${transition.to}',
            trigger: connectorTrigger,
          );

          // We only collects connectorIds here in a set as we need to
          // draw a single transition line per defined transition.
          connectorIds.add(connectorId);

          // Draw connection from connector to targeted entry point.
          assert(
            region?.machine.states[toEntryPointId] is EntryPoint,
            'State "$toEntryPointId" of machine named "${region?.machine.name}" '
            'shall be an EntryPoint.',
          );
          final to = _getPrefixedId(
            prefix: prefix,
            parentId: transition.to,
            regionNumber: i,
            childId: toEntryPointId,
          );
          if (!entryPoints.contains(to)) {
            _cWriteln('$connectorId -[${theme.connectorStyle}]-> $to');
            entryPoints.add(to);
          }
        }
      }

      for (final connectorId in connectorIds) {
        // Draw transition from source state to entry connector.
        _cWriteln(
          _getTransition(
            stateId: stateId,
            source: '$prefix.$stateId',
            target: connectorId,
            transitionId: transitionId,
            transition: transition,
            event: eventId,
          ),
        );
      }
    }

    // ---------------------------------------------------------------------
    // ExitConnector --> State
    // ---------------------------------------------------------------------

    final prefixedStateId = _getPrefixed(prefix: prefix, id: '$stateId');
    if (_shallWeShowRegions(_getStateName(prefixedStateId))) {
      for (final region in state.regions) {
        region.exitConnectors?.forEach((exitStateId, triggerEventId) {
          if (eventId == triggerEventId) {
            final source = _getExitConnectorId(
              statePrefix: '$prefix.$stateId',
              eventId: eventId,
            );
            if (!handled) {
              _cWriteln(
                _getTransition(
                  stateId: stateId,
                  source: source,
                  target: '$prefix.${transition.to}',
                  transitionId: transitionId,
                  transition: transition,
                  event: eventId,
                ),
              );
            }
            handled = true;
          }
        });
      }
    }

    // ---------------------------------------------------------------------
    // State --> State || EndPoint
    // ---------------------------------------------------------------------

    if (!handled) {
      _cWriteln(
        _getTransition(
          stateId: stateId,
          source: '$prefix.$stateId',
          target: '$prefix.${transition.to}',
          transitionId: transitionId,
          transition: transition,
          event: eventId,
        ),
      );
    }
  }

  void _writeStateWithStereotype(
    dynamic sourceStateId,
    String stereotype,
  ) {
    final sourceStateIdPrefixed = '$prefix.$sourceStateId';
    _cWriteln(
      'state "$sourceStateId" as $sourceStateIdPrefixed <<$stereotype>>',
    );
  }

  void _writeEntryPoint(
    dynamic sourceStateId,
  ) {
    final sourceStateIdPrefixed = '$prefix.$sourceStateId';
    _cWriteln(
      'state "$sourceStateId" as $sourceStateIdPrefixed <<entryPoint>>',
    );
  }

  /// Handling EntryPoint together with its internal transition.
  /// These must be inserted after ESM-s are processed as PlantUML only
  /// handles entry points correctly if they are used after the state
  /// where it connects to is already defined.
  void _writeEntryPointInternalTransitions(
    dynamic sourceStateId,
    EntryPoint<dynamic, dynamic, dynamic> entryPoint,
  ) {
    final sourceStateIdPrefixed = '$prefix.$sourceStateId';

    for (final transitionId in entryPoint.transitionIds) {
      final transition = machine.transitions[transitionId];
      assert(transition != null && transition is Transition<dynamic>);
      if (transition == null || transition is! Transition) continue;
      _drawEntryPointTransition(
        transition: transition,
        transitionId: transitionId,
        sourceStateId: sourceStateId,
        sourceStateIdPrefixed: sourceStateIdPrefixed,
      );
    }
  }

  void _drawEntryPointTransition({
    required Transition<dynamic> transition,
    required dynamic transitionId,
    required dynamic sourceStateId,
    required String sourceStateIdPrefixed,
  }) {
    // First we check each region of the target state defined by the
    // EntryPoint if their entryConnector map includes a matching
    // entrypoint id.
    final toState = machine.stateAt(transition.to);
    final trigger = Trigger<dynamic, dynamic, dynamic>(
      source: sourceStateId,
      event: null,
      transition: transitionId,
    );
    var handled = false;

    final prefixedEpToStateId =
        _getPrefixed(prefix: prefix, id: '${transition.to}');
    if (_shallWeShowRegions(_getStateName(prefixedEpToStateId))) {
      for (var i = 0; i < (toState?.regions.length ?? 0); i++) {
        final region = toState?.regions[i];
        final toEntryPointId = region?.entryConnectors?[trigger];
        if (toEntryPointId != null) {
          final toConnector = _getEntryConnectorId(
            statePrefix: '$prefix.${transition.to}',
            trigger: trigger,
          );
          // First draw transition from source state to entry connector.
          // '$sourceStateIdPrefixed -${_getTransitionPrefix()}> $toConnector';
          _cWriteln(
            _getTransition(
              stateId: sourceStateId,
              source: sourceStateIdPrefixed,
              target: toConnector,
              transitionId: transitionId,
              transition: transition,
              event: null,
            ),
          );

          final toSubMachineEntryPoint = _getPrefixedId(
            prefix: prefix,
            parentId: transition.to,
            regionNumber: i,
            childId: toEntryPointId,
          );
          // Then draw connection from connector to entry point.
          _cWriteln(
            '$toConnector -[${theme.connectorStyle}]-> $toSubMachineEntryPoint',
          );

          handled = true;
        }
      }
    }

    // If regions did not defined any matching entry-points then
    // we connect to the state defined in the entry-point.
    if (!handled) {
      _cWriteln(
        _getTransition(
          stateId: sourceStateId,
          source: sourceStateIdPrefixed,
          target: '$prefix.${transition.to}',
          transitionId: transitionId,
          transition: transition,
          event: null,
        ),
      );
    }
  }

  void _writeHistoryEntryPoint(
    dynamic stateId,
    HistoryEntryPoint<dynamic, dynamic, dynamic> state,
  ) {
    final stateIdPrefixed = '$prefix.$stateId';
    _cWriteln('$stateIdPrefixed -${_getTransitionPrefix()}> [H'
        '${state.level == HistoryLevel.deep ? '*' : ''}'
        ']');
  }

  void _writeExitPoint(
    dynamic stateId,
    BaseState<dynamic, dynamic, dynamic> state,
  ) {
    final stateIdPrefixed = '$prefix.$stateId';
    // We only make note of these exit points as
    _exits.add(ExitInfo(stateId: stateId, stateIdPrefixed: stateIdPrefixed));
    _cWriteln('state "$stateId" as $stateIdPrefixed <<exitPoint>>');
  }

  String _getPrefixedId({
    required String prefix,
    required dynamic parentId,
    required int regionNumber,
    required dynamic childId,
  }) {
    return '$prefix.$parentId.R$regionNumber.$childId';
  }

  void _writeDefaultHistoryTransition(HistoryLevel level) {
    _cWriteln('$prefix -${_getTransitionPrefix()}> [H'
        '${level == HistoryLevel.deep ? '*' : ''}'
        ']');
  }
}

class ExitInfo {
  ExitInfo({
    required this.stateId,
    required this.stateIdPrefixed,
  });

  final dynamic stateId;
  final String stateIdPrefixed;
}

//------------------------------------------------------------------------------
// Parent machine
//------------------------------------------------------------------------------
enum St { en1, s1, s2, s3, ex1 }

enum Ev { e1, e2, e3 }

enum Tr { t1, t2, t3 }

final sm = Machine<St, Ev, Tr>(
  events: Ev.values,
  name: 'm1',
  initialStateId: St.s1,
  states: {
    St.en1: EntryPoint([Tr.t1]),
    St.s1: State(
      etm: {
        Ev.e1: [Tr.t1],
        Ev.e3: [Tr.t3],
      },
    ),
    St.s2: State(
      etm: {
        Ev.e2: [Tr.t2],
      },
      regions: [
        Region<St, Ev, Tr, SS1>(
          machine: ssm1,
          entryConnectors: {
            Trigger(source: St.s1, event: Ev.e1, transition: Tr.t1): SS1.en1,
          },
          exitConnectors: {
            SS1.ex1: Ev.e2,
          },
        ),
      ],
    ),
    St.s3: State(
      regions: [
        Region<St, Ev, Tr, SS2>(machine: ssm2),
      ],
    ),
    St.ex1: ExitPoint(),
  },
  transitions: {
    Tr.t1: Transition(to: St.s2),
    Tr.t2: Transition(to: St.s3),
    Tr.t3: Transition(to: St.ex1),
  },
);

//------------------------------------------------------------------------------
// Child machines
//------------------------------------------------------------------------------
enum SS1 { en1, s1, s2, ex1 }

enum SE1 { e1, e2, e3 }

enum ST1 { t0, t1, t2, t3 }

final ssm1 = Machine<SS1, SE1, ST1>(
  events: SE1.values,
  name: 'cm1',
  initialStateId: SS1.s1,
  states: {
    SS1.en1: EntryPoint([ST1.t2]),
    SS1.s1: State(
      etm: {
        SE1.e1: [ST1.t1],
      },
    ),
    SS1.s2: State(
      etm: {
        SE1.e2: [ST1.t2],
        SE1.e3: [ST1.t3],
      },
    ),
    SS1.ex1: ExitPoint(),
  },
  // Why Transitions are at this level?
  transitions: {
    ST1.t0: Transition(to: SS1.en1),
    ST1.t1: Transition(to: SS1.s2),
    ST1.t2: Transition(to: SS1.s1),
    ST1.t3: Transition(to: SS1.ex1),
  },
);

enum SS2 { en1, s1, s2, ex1 }

enum SE2 { e1, e2, e3 }

enum ST2 { t0, t1, t2, t3 }

final ssm2 = Machine<SS2, SE2, ST2>(
  events: SE2.values,
  name: 'cm2',
  initialStateId: SS2.s1,
  states: {
    SS2.en1: EntryPoint([ST2.t2]),
    SS2.s1: State(
      etm: {
        SE2.e1: [ST2.t1],
      },
    ),
    SS2.s2: State(
      etm: {
        SE2.e2: [ST2.t2],
        SE2.e3: [ST2.t3],
      },
    ),
    SS2.ex1: ExitPoint(),
  },
  // Why Transitions are at this level?
  transitions: {
    ST2.t0: Transition(to: SS2.en1),
    ST2.t1: Transition(to: SS2.s2),
    ST2.t2: Transition(to: SS2.s1),
    ST2.t3: Transition(to: SS2.ex1),
  },
);

//------------------------------------------------------------------------------

class TransitionWithId {
  TransitionWithId({
    required this.id,
    required this.transition,
  });
  dynamic id;
  Transition<dynamic> transition;
}

String _getMachineName(String name) => 'MACHINE:$name';
String _getStateName(String name) => 'STATE:$name';

String _getPrefixed({
  required String prefix,
  required String id,
}) =>
    '$prefix.$id';

// Commented main out to avoid unreachable_from_main lint.
// Future<void> main() async {
//   // await sm.start();
//   // ignore: avoid_print
//   print(PlantUMLConverter(stateMachine: sm, expandedItems: {}).diagram);
//   // ignore: avoid_print
//   print(SS1.en1);
//   await Future<void>.delayed(const Duration(seconds: 1));
//   await sm.start();
// }
