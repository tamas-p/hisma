import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../machine/comp_f_machine.dart';
import '../ui/comp_f_screen_a.dart';
import '../ui/comp_f_screen_c.dart';

final fRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, Widget, E>(
    machine: ref.read(compFMachineProvider),
    creators: {
      S.a: MaterialPageCreator<S>(widget: const CompFScreenA()),
      S.b: getPagelessCreator(),
      // S.b: MaterialPageCreator<S>(widget: const CompFScreenB()),
      S.c: MaterialPageCreator<S>(widget: const CompFScreenC()),
    },
  ),
);

PagelessCreator<E, bool?> getPagelessCreator() => PagelessCreator<E, bool?>(
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
    );
