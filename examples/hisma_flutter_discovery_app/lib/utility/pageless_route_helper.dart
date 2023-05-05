import 'package:flutter/material.dart';
import 'package:hisma_flutter/hisma_flutter.dart';

class DialogPagelessRouteManager<T> implements PagelessRouteManager<T> {
  DialogPagelessRouteManager({required this.title, required this.text});

  final String title;
  final String text;
  BuildContext? _context;

  @override
  Future<T?> open(BuildContext context) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        _context = context;
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
                close();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void close([T? value]) {
    final context = _context;
    if (context != null) Navigator.of(context).pop();
  }
}

class DatePickerPagelessRouteManager implements PagelessRouteManager<DateTime> {
  BuildContext? _context;
  @override
  Future<DateTime?> open(BuildContext context) {
    _context = context;
    return showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      initialDate: DateTime.now(),
      currentDate: DateTime.now(),
      lastDate: DateTime(2028),
    );
  }

  @override
  void close([DateTime? value]) {
    final context = _context;
    if (context != null) Navigator.of(context, rootNavigator: true).pop();
  }
}

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
