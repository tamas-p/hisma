import 'package:flutter/material.dart';

Future<void> createDialog({
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
