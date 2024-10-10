import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../hisma_flutter.dart';
import 'assistance.dart';
import 'hisma_router_delegate.dart';

/*
@startuml
abstract class Presentation
abstract class Creator<E> {
  E? event
}
class NoUIChange
abstract class PageCreator<E, R> {
  Widget widget
  bool overlay
  Page<R> Function({required Widget widget, required String name}) create
}
class MaterialPageCreator<E, R>
class CupertinoPageCreator<E, R>
abstract class OpenCloseCreator<E, R> {
  Future<R?> open(BuildContext context)
  void close([R? value])
}
class DialogCreator<E, R> {
  final bool useRootNavigator;
  final Future<R?> Function(DialogCreator<E, R> dc, BuildContext context) show;
}

Presentation <|-- NoUIChange
Presentation <|-- Creator
Creator <|-- PageCreator
Creator <|-- OpenCloseCreator

PageCreator <|-- MaterialPageCreator
PageCreator <|-- CupertinoPageCreator

OpenCloseCreator <|-- PagelessCreator
OpenCloseCreator <|-- BottomSheetCreator
OpenCloseCreator <|-- SnackBarCreator

@enduml
*/

final Logger _log = Logger('creator');

/// Presentation of state machine states.
abstract class Presentation {}

/// User interface representation of state machine states.
abstract class Creator<E> extends Presentation {
  Creator({this.event});
  E? event;
}

/// Use this class to indicate for [HismaRouterDelegate] that when machine
/// arrives to this state the user interface shall not be updated (e.g this
/// state is transitional, only does some service invocation or computing).
/// It is a better approach than silent no-update on UI if a state is not
/// defined in the creator map of [HismaRouterDelegate]. This way we get
/// assertion failed in case the machine gets to a state that is not defined in
/// the creator list. Alternative is using an [InternalTransition].
class NoUIChange extends Presentation {}

//-----------------------------------------------------------------------------

/// Eliminates redundancy of giving stateId twice when defining creator maps
/// (mapping) of [HismaRouterGenerator]. With the help of this class
/// [HismaRouterDelegate] will call the [create] function with a given state.
abstract class PageCreator<E, R> extends Creator<E> {
  PageCreator({
    required this.widget,
    required this.create,
    this.overlay = false,
    super.event,
  });
  final Widget widget;
  final Page<R> Function({
    required Widget widget,
    required String name,
  }) create;
  final bool overlay;
}

abstract class PagelessCreator<E, R> extends Creator<E> {
  PagelessCreator({required super.event});

  Future<R?> open(BuildContext context);
  void close([R? value]);
}

class DialogCreator<E, R> extends PagelessCreator<E, R> {
  DialogCreator({
    required this.show,
    required super.event,
    required this.useRootNavigator,
  });

  final bool useRootNavigator;
  final Future<R?> Function(DialogCreator<E, R> dc, BuildContext context) show;
  BuildContext? context;

  @override
  Future<R?> open(BuildContext context) {
    this.context = context;
    return show(this, context);
  }

  @override
  void close([R? value]) {
    final context = this.context;
    if (context != null) {
      // TODO: When Flutter version > 3.7 use the context.mounted instead.
      try {
        (context as Element).widget;
      } catch (e) {
        // TODO: We shall never get there. It only happens during during
        // consecutive execution of widget tests. To be investigated.
        _log.info('No render-object found. Widget is not mounted.');
        return;
      }
      Navigator.of(context, rootNavigator: useRootNavigator).pop(value);
    }
  }
}

class SnackBarCreator<E> extends PagelessCreator<E, CtxArg> {
  SnackBarCreator({
    required this.snackBar,
    required super.event,
  });

  SnackBar snackBar;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? ret;

  @override
  Future<CtxArg?> open(BuildContext context) async {
    ret = ScaffoldMessenger.of(context).showSnackBar(snackBar);
    final res =
        ret != null ? ret!.closed : Future<SnackBarClosedReason?>.value();
    final r = await res;
    // ignore: use_build_context_synchronously
    return CtxArg(context, r);
  }

  @override
  void close([CtxArg? value]) {
    ret?.close();
  }
}

// class BottomSheetCreator<T, E> extends PagelessCreator<T, E> {
//   BottomSheetCreator({
//     required this.useRootNavigator,
//     required this.show,
//     required super.event,
//   });

//   final bool useRootNavigator;
//   final PersistentBottomSheetController<T> Function(
//     BottomSheetCreator<T, E> dc,
//     BuildContext context,
//   ) show;

//   @override
//   Future<T?> open(BuildContext context) {
//     final ret = show.call(this, context);
//   }

//   @override
//   void close([SnackBarClosedReason? value]) {
//     // TODO: implement close
//   }
// }

class MaterialPageCreator<E, R> extends PageCreator<E, R> {
  // TODO: should the event be required here if overlay = true?
  // YES, it should be mandatory, otherwise when Flutter pops when
  // user clicks on AppBar BackButton the ui changes, but state remain
  // resulting inconsistent UI.
  MaterialPageCreator({
    required super.widget,
    super.overlay,
    super.event,
  }) : super(create: _createPage<R>);
}

Page<R> _createPage<R>({
  required Widget widget,
  required String name,
}) {
  // print('__createPage: $name');
  return MaterialPage<R>(
    child: widget,

    // TODO: consider using path as defined in state machine hierarchy.
    // OR simply use S stateId as the ValueKey only has to be unique for
    // one machine as there is a 1-1 relation between machines and navigator
    // states.
    key: ValueKey(name),
    name: name,
  );
}

/// Only for debugging purposes.
class LoggingMaterialPage<W> extends MaterialPage<W> {
  const LoggingMaterialPage({
    required super.child,
    super.key,
    super.name,
  });

  static final _log = getLogger('$LoggingMaterialPage');

  @override
  bool canUpdate(Page<dynamic> other) {
    // ignore: no_runtimetype_tostring
    _log.fine('canUpdate: runtimeType=$runtimeType');
    _log.fine('canUpdate: other.runtimeType=${other.runtimeType}');
    _log.fine('canUpdate: key=$key');
    _log.fine('canUpdate: other.key=${other.key}');
    return other.runtimeType == runtimeType && other.key == key;
  }

  @override
  Route<W> createRoute(BuildContext context) {
    _log.fine('createRoute($context)');
    return super.createRoute(context);
  }
}
