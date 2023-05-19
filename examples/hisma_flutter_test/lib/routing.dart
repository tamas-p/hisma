import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import 'machine.dart';
import 'ui.dart';

HismaRouterGenerator<S, Widget, E> createHismaRouterGenerator(
  StateMachineWithChangeNotifier<S, E, T> machine, [
  int level = 0,
]) =>
    HismaRouterGenerator<S, Widget, E>(
      machine: machine,
      mapping: {
        S.a: MaterialPageCreator<S, E>(widget: Screen(machine, S.a)),
        S.b: MaterialPageCreator<S, E>(widget: Screen(machine, S.b)),
        S.c: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.c),
          event: E.back,
          overlay: true,
        ),
        // S.d: DialogCreator(
        //   machine: machine,
        //   stateId: S.d,
        //   event: E.self,
        // ),
        S.d: MaterialPageCreator<S, E>(widget: Screen(machine, S.d)),
        // S.e: DialogCreator(
        //   machine: machine,
        //   stateId: S.e,
        //   event: E.self,
        // ),
        S.e: MaterialPageCreator<S, E>(widget: Screen(machine, S.e)),
        // S.f: DialogCreator(
        //   machine: machine,
        //   stateId: S.f,
        //   event: E.self,
        // ),
        S.f: MaterialPageCreator<S, E>(widget: Screen(machine, S.f)),
        S.g: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.g),
          overlay: true,
          event: E.back,
        ),
        // S.h: DialogCreator(
        //   machine: machine,
        //   stateId: S.h,
        //   event: E.self,
        // ),
        S.h: MaterialPageCreator<S, E>(widget: Screen(machine, S.h)),
        S.i: MaterialPageCreator<S, E>(widget: Screen(machine, S.i)),
        S.j: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.j),
          overlay: true,
          event: E.back,
        ),
        if (level == 0 || level == 1 || level == 2)
          // if (false)
          S.k: MaterialPageCreator<S, E>(
            widget: Router(
              routerDelegate: createHismaRouterGenerator(
                machine.find(getName(machine.name, S.k)),
                level + 1,
              ).routerDelegate,
            ),
          )
        else
          S.k: MaterialPageCreator<S, E>(
            widget: Screen(machine, S.k),
            overlay: true,
            event: E.back,
          ),
        if (level == 0 || level == 1 || level == 2)
          // if (false)
          S.l: MaterialPageCreator<S, E>(
            widget: Router(
              routerDelegate: createHismaRouterGenerator(
                machine.find(getName(machine.name, S.l)),
                level + 1,
              ).routerDelegate,
            ),
          )
        else
          // S.l: DialogCreator(
          //   machine: machine,
          //   stateId: S.l,
          //   event: E.self,
          // ),
          S.l: MaterialPageCreator<S, E>(widget: Screen(machine, S.l)),
        // S.m: DialogCreator(
        //   machine: machine,
        //   stateId: S.m,
        //   event: E.self,
        // ),
        S.m: MaterialPageCreator<S, E>(widget: Screen(machine, S.m)),
        S.n: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.n),
          overlay: true,
          event: E.back,
        ),
      },
    );
