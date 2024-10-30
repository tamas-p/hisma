import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

Future<T?> generateDialog<T, E>({
  required OldDialogCreator<T, E> dc,
  required BuildContext context,
  required String title,
  required String text,
}) =>
    showDialog<T>(
      useRootNavigator: dc.useRootNavigator,
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
                dc.close();
              },
            ),
          ],
        );
      },
    );

Future<DateTime?> generateDatePicker<E>(
  OldDialogCreator<E, DateTime> dc,
  BuildContext context,
) =>
    showDatePicker(
      useRootNavigator: dc.useRootNavigator,
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
