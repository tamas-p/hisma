import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../machine/comp_a_a_machine.dart';
import '../ui/comp_a_a_screen_a.dart';
import '../ui/comp_a_a_screen_b.dart';
import '../ui/comp_a_a_screen_c.dart';
import '../ui/comp_a_a_screen_o.dart';

final l2aRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, Widget, E>(
    machine: ref.read(compL2AMachineProvider),
    creators: {
      S.l2a: MaterialPageCreator<S>(widget: const CompL2AScreenA()),
      S.l2o: OverlayMaterialPageCreator<S, E>(
        widget: const CompL2AScreenO(),
        event: E.jump,
      ),
      S.l2a1: PagelessCreator<E, bool?>(
        rootNavigator: false,
        show: (context) {
          print('~~~~~ Creating about dialog.');
          print('~~~~~ context: $context');
          print('~~~~~ Navigator.of(context)=${Navigator.of(context)}');
          return showDialog(
            context: context,
            useRootNavigator: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Problem during login'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const <Widget>[
                      Text('Hello'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      print(
                        '~~~~~ onPressed: Navigator.of(context)=${Navigator.of(context)}',
                      );
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        },
        event: E.backward,
      ),
      S.l2b: MaterialPageCreator<S>(widget: const CompL2AScreenB()),
      S.l2c: MaterialPageCreator<S>(widget: const CompL2AScreenC()),
    },
  ),
);
