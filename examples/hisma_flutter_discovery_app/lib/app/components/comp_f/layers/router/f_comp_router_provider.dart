import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

import '../../../../../utility/pageless_route_helper.dart';
import '../machine/comp_f_machine.dart';
import '../ui/comp_f_screen_a.dart';
import '../ui/comp_f_screen_c.dart';

final fRouterProvider = Provider(
  (ref) => HismaRouterGenerator<S, E>(
    machine: ref.read(compFMachineProvider),
    mapping: {
      S.fa: MaterialPageCreator<void, S, E>(widget: const CompFScreenA()),
      // S.fb: getPagelessCreator2(),
      S.fb: DialogCreator<void, E>(
        useRootNavigator: true,
        event: E.backward,
        show: (dc, context) => generateDialog(
          dc: dc,
          context: context,
          title: 'Test1',
          text: 'Demo test1.',
        ),
      ),
      // S.b: MaterialPageCreator<S>(widget: const CompFScreenB()),
      S.fc: MaterialPageCreator<void, S, E>(widget: const CompFScreenC()),
    },
  ),
);

/*
PagelessCreatorOld<E, void> getPagelessCreator2() =>
    PagelessCreatorOld<E, void>(
      rootNavigator: false,
      event: E.backward,
      show: (
        context, {
        void Function(BuildContext)? setContext,
      }) {
        final snackBar = SnackBar(
          content: const Text('Hi, I am a SnackBar!'),
          backgroundColor: Colors.black12,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'dismiss',
            onPressed: () {},
          ),
        );
        final completer = Completer<void>();

        final ret = ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return ret.closed;
      },
    );

PagelessCreatorOld<E, bool?> getPagelessCreator() =>
    PagelessCreatorOld<E, bool?>(
      rootNavigator: false,
      show: (
        context, {
        void Function(BuildContext)? setContext,
      }) {
        print('~~~~~ Creating about dialog.');
        print('~~~~~ context: $context');
        print('~~~~~ Navigator.of(context)=${Navigator.of(context)}');
        return showDialog(
          context: context,
          // useRootNavigator: false,
          builder: (BuildContext context) {
            setContext?.call(context);
            print(
              '~~~~~ dialog build: context=${context.hashCode}\n'
              '~~~~~ dialog build: Navigator.of(context)=${Navigator.of(context)}',
            );
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
                      '~~~~~ onPressed: context=${context.hashCode}\n'
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
*/