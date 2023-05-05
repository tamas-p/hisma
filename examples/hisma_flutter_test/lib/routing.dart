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
        S.d: DialogCreator(
          machine: machine,
          stateId: S.d,
          event: E.self,
        ),
        S.e: DialogCreator(
          machine: machine,
          stateId: S.e,
          event: E.self,
        ),
        S.f: DialogCreator(
          machine: machine,
          stateId: S.f,
          event: E.self,
        ),
        S.g: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.g),
          overlay: true,
          event: E.back,
        ),
        S.h: DialogCreator(
          machine: machine,
          stateId: S.h,
          event: E.self,
        ),
        S.i: MaterialPageCreator<S, E>(widget: Screen(machine, S.i)),
        S.j: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.j),
          // overlay: true,
          event: E.back,
        ),
        if (level == 0 || level == 1 || level == 2)
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
          S.l: MaterialPageCreator<S, E>(
            widget: Router(
              routerDelegate: createHismaRouterGenerator(
                machine.find(getName(machine.name, S.l)),
                level + 1,
              ).routerDelegate,
            ),
          )
        else
          S.l: DialogCreator(
            machine: machine,
            stateId: S.l,
            event: E.self,
          ),
        S.m: DialogCreator(
          machine: machine,
          stateId: S.m,
          event: E.self,
        ),
        S.n: MaterialPageCreator<S, E>(
          widget: Screen(machine, S.n),
          overlay: true,
          event: E.back,
        ),
      },
    );
