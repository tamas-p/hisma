import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

Future<void> createDialog({
  required DialogCreator<dynamic, dynamic> dc,
  required BuildContext context,
  required bool useRootNavigator,
  required String title,
  required String message,
}) =>
    showDialog<void>(
      useRootNavigator: useRootNavigator,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Err: $message'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                dc.close();
              },
            ),
          ],
        );
      },
    );
