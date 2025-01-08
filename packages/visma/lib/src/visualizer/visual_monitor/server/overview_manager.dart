import 'dart:collection';

import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import 'browser_notifier.dart';
import 'statemachine_manager.dart';

/* Data model for state machines overview:
@startuml
Hosts o-- Domains
Hostname .. (Hosts, Domains) 

Domains o-- StateMachines
DomainName .. (Domains, StateMachines)

StateMachines "childMachines" o-- ChildMachine
StateMachines "machines" o-- Machine
StateMachineId .. (StateMachines, Machine) 
@enduml
*/
typedef Hosts = Map<Hostname, Domains>;
typedef Hostname = String;
typedef Domains = Map<DomainName, StateMachines>;
typedef DomainName = String;

class StateMachines {
  final SplayTreeSet<String> childMachines =
      SplayTreeSet<String>.from(<String>{});
  final Map<String, SplayTreeSet<String>> machines = {};
}

class OverviewManager with BrowserNotifier {
  Theme theme = Theme.dark();
  final _hosts = <Hostname, Domains>{};

  void add({
    required StateMachineId uniqueSmId,
    required Set<String> children,
  }) {
    _hosts.putIfAbsent(
      uniqueSmId.hostname,
      () => Domains.from(<DomainName, StateMachines>{}),
    );
    final domains = _hosts[uniqueSmId.hostname]!;

    domains.putIfAbsent(uniqueSmId.domain, () => StateMachines());
    final stateMachines = domains[uniqueSmId.domain]!;

    stateMachines.childMachines.addAll(children);
    stateMachines.machines[uniqueSmId.smId] = SplayTreeSet.from(children);

    notifyViewers();
  }

  void remove(StateMachineId uniqueSmId) {
    final childMachines =
        _hosts[uniqueSmId.hostname]?[uniqueSmId.domain]?.childMachines;
    childMachines?.remove(uniqueSmId.smId);

    final machines = _hosts[uniqueSmId.hostname]?[uniqueSmId.domain]?.machines;
    machines?.remove(uniqueSmId.smId);

    final domains = _hosts[uniqueSmId.hostname];
    if (childMachines != null &&
        childMachines.isEmpty &&
        machines != null &&
        machines.isEmpty) {
      domains?.remove(uniqueSmId.domain);
    }

    if (domains != null && domains.isEmpty) {
      _hosts.remove(uniqueSmId.hostname);
    }

    notifyViewers();
  }

  /// Renders a tree structure for all state machine registered
  /// based on their parent-child relationship in PlantUML format e.g.:
  /// @startmindmap State machine hierarchy diagram
  /// * All machines
  /// ** sm1
  /// *** subSm1
  /// **** subSubSm0
  /// *** subSm2
  /// **** subSubSm1
  /// **** subSubSm2
  /// **** subSubSm3
  /// ** sm2
  /// @endmindmap
  String render() {
    final strBuf = StringBuffer();

    // !pragma layout smetana
    final prelude = '''
@startmindmap State machine hierarchy diagram
<style>
  mindmapDiagram {
    BackgroundColor ${theme.backgroundColor}  
    LineColor ${theme.passiveTransitionColor}
    node {
      BackgroundColor ${theme.backgroundColor}
      LineColor ${theme.lineColor}
      FontColor ${theme.lineColor}
      HyperLinkColor ${theme.lineColor}
    }
    :depth(0) {
      BackGroundColor ${theme.highlightColor}
    }
    :depth(1) {
      BackGroundColor ${theme.highlightColor}
    }
    :depth(2) {
      BackGroundColor ${theme.highlightColor}
    }
  }
</style>
* SM Watcher
''';

    strBuf.write(prelude);
    strBuf.write(_renderHosts());
    strBuf.write(_epilogue);
    return strBuf.toString();
  }

  String _renderHosts() {
    final strBuf = StringBuffer();
    _hosts.forEach((hostname, domains) {
      strBuf.writeln('** $hostname');
      strBuf.write(_renderDomains(hostname, domains));
    });
    return strBuf.toString();
  }

  String _renderDomains(String hostname, Domains domains) {
    final strBuf = StringBuffer();
    domains.forEach((domain, stateMachines) {
      strBuf.writeln('*** $domain');
      strBuf.write(
        _renderMachines(
          linkPrefix: getLinkPrefix(hostname, domain),
          stateMachines: stateMachines,
        ),
      );
    });
    return strBuf.toString();
  }

  Iterable<String> _getRootMachines(StateMachines stateMachines) sync* {
    for (final e in stateMachines.machines.entries) {
      if (!stateMachines.childMachines.contains(e.key)) {
        yield e.key;
      }
    }
  }

  String _renderMachines({
    required String linkPrefix,
    required StateMachines stateMachines,
  }) {
    const prefix = '**** ';
    final strBuf = StringBuffer();
    // _rootMachines.sort();
    for (final rootMachine in _getRootMachines(stateMachines)) {
      final encodedRootMachine = Uri.encodeComponent(rootMachine);
      strBuf.writeln(
        '$prefix[[$linkPrefix$encodedRootMachine $rootMachine]]',
      );
      final res = _renderChildren(
        prefix: '*$prefix',
        parentMachine: rootMachine,
        linkPrefix: linkPrefix,
        stateMachines: stateMachines,
      );
      if (res.isNotEmpty) strBuf.write(res);
    }

    return strBuf.toString();
  }

  String _renderChildren({
    required String prefix,
    required String parentMachine,
    required String linkPrefix,
    required StateMachines stateMachines,
  }) {
    final strBuf = StringBuffer();
    final children = stateMachines.machines[parentMachine];
    // children?.sort();
    for (final childMachine in children ?? <String>{}) {
      final encodedChildMachine = Uri.encodeComponent(childMachine);
      strBuf.writeln(
        '$prefix[[$linkPrefix$encodedChildMachine $childMachine]]',
      );
      final res = _renderChildren(
        prefix: '*$prefix',
        parentMachine: childMachine,
        linkPrefix: linkPrefix,
        stateMachines: stateMachines,
      );
      if (res.isNotEmpty) strBuf.write(res);
    }
    return strBuf.toString();
  }
}

const _epilogue = '''
@endmindmap
''';
