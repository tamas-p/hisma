import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../ui.dart';
import 'machine.dart';
import 'states_events_transitions.dart';

HismaRouterGenerator<S, E> createHismaRouterGenerator({
  required NavigationMachine<S, E, T> machine,
  required bool useRootNavigator,
}) {
  return HismaRouterGenerator<S, E>(
    machine: machine,
    mapping: {
      S.a: MaterialPageCreator<E, void>(widget: Screen(machine)),
      S.b: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        event: E.back,
      ),
      S.c: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        event: E.back,
        overlay: true,
      ),
      S.d: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: useRootNavigator,
        machine: machine,
        event: E.self,
      ),
      // S.d: MaterialPageCreator<E, void>(widget: Screen(machine, S.d)),
      S.e: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: useRootNavigator,
        machine: machine,
        event: E.self,
      ),
      // S.e: MaterialPageCreator<E, void>(widget: Screen(machine, S.e)),
      S.f: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: useRootNavigator,
        machine: machine,
        event: E.self,
      ),
      // S.f: MaterialPageCreator<E, void>(widget: Screen(machine, S.f)),
      S.g: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
      S.h: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: useRootNavigator,
        machine: machine,
        event: E.self,
      ),
      // S.h: MaterialPageCreator<E, void>(widget: Screen(machine, S.h)),
      S.i: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
      S.j: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
      if (machine.name.split('/').length < hierarchyDepth + 1)
        S.k: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return RouterWithDelegate<S>(
                () => createHismaRouterGenerator(
                  machine: machine.find<S, E, T>(
                    getMachineName(machine.name, S.k),
                  ),
                  useRootNavigator: useRootNavigator,
                ).routerDelegate,
              );
            },
          ),
        )
      else
        S.k: MaterialPageCreator<E, void>(
          widget: Screen(machine),
          overlay: true,
          event: E.back,
        ),
      if (machine.name.split('/').length < hierarchyDepth + 1)
        S.l: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return RouterWithDelegate(
                () => createHismaRouterGenerator(
                  machine: machine.find<S, E, T>(
                    getMachineName(machine.name, S.l),
                  ),
                  useRootNavigator: useRootNavigator,
                ).routerDelegate,
              );
            },
          ),
        )
      else
        S.l: PagelessCreator<E, void>(
          present: showTestDialog,
          rootNavigator: useRootNavigator,
          machine: machine,
          event: E.self,
        ),
      // S.l: MaterialPageCreator<E, void>(widget: Screen(machine, S.l)),
      S.m: PagelessCreator<E, void>(
        present: showTestDialog,
        rootNavigator: useRootNavigator,
        machine: machine,
        event: E.self,
      ),
      // S.m: MaterialPageCreator<E, void>(widget: Screen(machine, S.m)),
      S.n: MaterialPageCreator<E, void>(
        widget: Screen(machine),
        overlay: true,
        event: E.back,
      ),
    },
  );
}


/*
class HismaRouterGeneratorManager {
  factory HismaRouterGeneratorManager(
    StateMachineWithChangeNotifier<S, E, T> machine,
  ) {
    // If _instance was already set we replace it now.
    return _instance = HismaRouterGeneratorManager._internal(machine);
  }
  HismaRouterGeneratorManager._internal(this._machine);

  static late HismaRouterGeneratorManager _instance;
  static HismaRouterGeneratorManager get instance => _instance;

  final StateMachineWithChangeNotifier<S, E, T> _machine;
  final Map<String, HismaRouterGenerator<S, E>> _map = {};

  HismaRouterGenerator<S, E> getRG({
    required String machineName,
    required int level,
    required bool useRootNavigator,
  }) {
    if (!_map.containsKey(machineName)) {
      _map[machineName] = createHismaRouterGenerator(
        machine: _machine.find(machineName),
        level: level,
        useRootNavigator: useRootNavigator,
      );
    }
    return _map[machineName]!;
  }
}
*/
