import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart';
import 'states_events_transitions.dart';
import 'ui.dart';

HismaRouterGenerator<S, E> createHismaRouterGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
  int level = 0,
}) {
  if (level == 0) HismaRouterGeneratorManager(machine);
  return HismaRouterGenerator<S, E>(
    machine: machine,
    mapping: {
      S.a: MaterialPageCreator<E, void>(widget: Screen(machine, S.a)),
      S.b: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.b),
        event: E.back,
      ),
      S.c: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.c),
        event: E.back,
        // TODO: When E.self, we shall have get back to Screen S.c here.
        // Right now Flutter pops the Screen S.c and we see Screen S.b and
        // we are NOT taken back/shown Screen S.c.
        // event: E.self,
        overlay: true,
      ),
      S.d: TestDialogCreator(
        machine: machine,
        stateId: S.d,
        event: E.self,
        useRootNavigator: useRootNavigator,
      ),
      // S.d: MaterialPageCreator<E, void>(widget: Screen(machine, S.d)),
      S.e: TestDialogCreator(
        machine: machine,
        stateId: S.e,
        event: E.self,
        useRootNavigator: useRootNavigator,
      ),
      // S.e: MaterialPageCreator<E, void>(widget: Screen(machine, S.e)),
      S.f: TestDialogCreator(
        machine: machine,
        stateId: S.f,
        event: E.self,
        useRootNavigator: useRootNavigator,
      ),
      // S.f: MaterialPageCreator<E, void>(widget: Screen(machine, S.f)),
      S.g: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.g),
        overlay: true,
        event: E.back,
      ),
      S.h: TestDialogCreator(
        machine: machine,
        stateId: S.h,
        event: E.self,
        useRootNavigator: useRootNavigator,
      ),
      // S.h: MaterialPageCreator<E, void>(widget: Screen(machine, S.h)),
      S.i: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.i),
        overlay: true,
        event: E.back,
      ),
      S.j: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.j),
        overlay: true,
        event: E.back,
      ),
      if (level < hierarchyDepth)
        S.k: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return Router(
                routerDelegate: HismaRouterGeneratorManager.instance
                    .getRG(
                      machineName: getName(machine.name, S.k),
                      level: level + 1,
                      useRootNavigator: useRootNavigator,
                    )
                    .routerDelegate,
                backButtonDispatcher: Router.of(context)
                    .backButtonDispatcher
                    ?.createChildBackButtonDispatcher()
                  ?..takePriority(),
              );
            },
          ),
        )
      else
        S.k: MaterialPageCreator<E, void>(
          widget: Screen(machine, S.k),
          overlay: true,
          event: E.back,
        ),
      if (level < hierarchyDepth)
        S.l: MaterialPageCreator<E, void>(
          widget: Builder(
            builder: (context) {
              return Router(
                routerDelegate: HismaRouterGeneratorManager.instance
                    .getRG(
                      machineName: getName(machine.name, S.l),
                      level: level + 1,
                      useRootNavigator: useRootNavigator,
                    )
                    .routerDelegate,
                backButtonDispatcher: Router.of(context)
                    .backButtonDispatcher
                    ?.createChildBackButtonDispatcher()
                  ?..takePriority(),
              );
            },
          ),
        )
      else
        S.l: TestDialogCreator(
          machine: machine,
          stateId: S.l,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
      // S.l: MaterialPageCreator<E, void>(widget: Screen(machine, S.l)),
      S.m: TestDialogCreator(
        machine: machine,
        stateId: S.m,
        event: E.self,
        useRootNavigator: useRootNavigator,
      ),
      // S.m: MaterialPageCreator<E, void>(widget: Screen(machine, S.m)),
      S.n: MaterialPageCreator<E, void>(
        widget: Screen(machine, S.n),
        overlay: true,
        event: E.back,
      ),
    },
  );
}

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
