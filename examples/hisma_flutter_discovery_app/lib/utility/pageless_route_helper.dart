import 'package:flutter/material.dart';

Future<R?> generateDialog<R, E>({
  required BuildContext context,
  required bool rootNavigator,
  required String title,
  required String text,
}) =>
    showDialog<R>(
      useRootNavigator: rootNavigator,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(text)],
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

Future<DateTime?> generateDatePicker<E>(
  BuildContext context,
  bool rootNavigator,
) =>
    showDatePicker(
      useRootNavigator: rootNavigator,
      context: context,
      firstDate: DateTime(2021),
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      lastDate: DateTime(2028),
    );

/*
class SnackbarPagelessRouteManager
    implements PagelessRouteManager<SnackBarClosedReason> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? ret;

  @override
  Future<SnackBarClosedReason> open(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Hi, I am a SnackBar!'),
      backgroundColor: Colors.black12,
      duration: const Duration(seconds: 10),
      action: SnackBarAction(
        label: 'dismiss',
        onPressed: () {},
      ),
    );

    ret = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return ret!.closed;
  }

  @override
  void close([void value]) {
    ret?.close();
  }
}
*/
