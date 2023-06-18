import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart';
import 'ui.dart';

HismaRouterGenerator<S, E> createHismaRouterGenerator({
  required StateMachineWithChangeNotifier<S, E, T> machine,
  required bool useRootNavigator,
  int level = 0,
}) =>
    HismaRouterGenerator<S, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.a)),
        S.b: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.b)),
        S.c: MaterialPageCreator<void, S, E>(
          widget: Screen(machine, S.c),
          event: E.back,
          // TODO: When E.self, we shall have get back to Screen S.c here.
          // Right now Flutter pops the Screen S.c and we see Screen S.b and
          // we are NOT taken back/shown Screen S.c.
          // event: E.self,
          overlay: true,
        ),
        S.d: DialogCreator(
          machine: machine,
          stateId: S.d,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
        // S.d: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.d)),
        S.e: DialogCreator(
          machine: machine,
          stateId: S.e,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
        // S.e: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.e)),
        S.f: DialogCreator(
          machine: machine,
          stateId: S.f,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
        // S.f: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.f)),
        S.g: MaterialPageCreator<void, S, E>(
          widget: Screen(machine, S.g),
          overlay: true,
          event: E.back,
        ),
        S.h: DialogCreator(
          machine: machine,
          stateId: S.h,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
        // S.h: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.h)),
        S.i: MaterialPageCreator<void, S, E>(
          widget: Screen(machine, S.i),
          overlay: true,
          event: E.back,
        ),
        S.j: MaterialPageCreator<void, S, E>(
          widget: Screen(machine, S.j),
          overlay: true,
          event: E.back,
        ),
        if (level < hierarchyDepth)
          S.k: MaterialPageCreator<void, S, E>(
            widget: Router(
              routerDelegate: createHismaRouterGenerator(
                machine: machine.find(getName(machine.name, S.k)),
                level: level + 1,
                useRootNavigator: useRootNavigator,
              ).routerDelegate,
            ),
          )
        else
          S.k: MaterialPageCreator<void, S, E>(
            widget: Screen(machine, S.k),
            overlay: true,
            event: E.back,
          ),
        if (level < hierarchyDepth)
          S.l: MaterialPageCreator<void, S, E>(
            widget: Router(
              routerDelegate: createHismaRouterGenerator(
                machine: machine.find(getName(machine.name, S.l)),
                level: level + 1,
                useRootNavigator: useRootNavigator,
              ).routerDelegate,
            ),
          )
        else
          S.l: DialogCreator(
            machine: machine,
            stateId: S.l,
            event: E.self,
            useRootNavigator: useRootNavigator,
          ),
        // S.l: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.l)),
        S.m: DialogCreator(
          machine: machine,
          stateId: S.m,
          event: E.self,
          useRootNavigator: useRootNavigator,
        ),
        // S.m: MaterialPageCreator<void, S, E>(widget: Screen(machine, S.m)),
        S.n: MaterialPageCreator<void, S, E>(
          widget: Screen(machine, S.n),
          overlay: true,
          event: E.back,
        ),
      },
    );
