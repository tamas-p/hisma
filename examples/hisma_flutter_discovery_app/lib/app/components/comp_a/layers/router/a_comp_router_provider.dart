import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../components/comp_a_a/layers/routing/a_a_comp_router_provider.dart';
import '../machine/comp_a_machine.dart';
import '../ui/comp_a_screen_b.dart';
import '../ui/comp_a_screen_c.dart';

final aRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, Widget, E>(
    machine: ref.read(compAMachineProvider),
    creators: {
      // S.ca: MaterialPageCreator<S>(widget: const CompAScreenA()),
      S.ca: MaterialPageCreator<S>(
        // widget: const StatelessScreen(),
        // widget: const StatefulScreen(),
        widget:
            Router(routerDelegate: ref.read(l2aRouterProvider).routerDelegate),
      ),
      S.ca1: PagelessCreator<E, bool?>(
        show: (context) {
          print('~~~~~ Creating about dialog.');
          print('~~~~~ context: $context');
          print('~~~~~ Navigator.of(context)=${Navigator.of(context)}');
          return showDialog(
            context: context,
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
      S.ca2: NoUIChange(),
      S.cb: MaterialPageCreator<S>(widget: const CompAScreenB()),
      S.cc: MaterialPageCreator<S>(widget: const CompAScreenC()),
    },
  ),
);
