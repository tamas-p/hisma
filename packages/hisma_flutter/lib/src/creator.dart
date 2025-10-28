import 'package:flutter/material.dart';
import 'package:hisma/hisma.dart';

import '../hisma_flutter.dart';
import 'assistance.dart';

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
abstract class ImperativeCreator<E, R> {
  Future<R?> open(BuildContext context)
  void close([R? value])
}
class PagelessCreator<E, R>
class BottomSheetCreator<E, R>
class SnackBarCreator<E, R>

Presentation <|-- NoUIChange
Presentation <|-- Creator
Creator <|-- PageCreator
Creator <|-- ImperativeCreator

PageCreator <|-- MaterialPageCreator
PageCreator <|-- CupertinoPageCreator

ImperativeCreator <|-- PagelessCreator
ImperativeCreator <|-- BottomSheetCreator
ImperativeCreator <|-- SnackBarCreator

@enduml
*/

/// Presentation of state machine states.
abstract class Presentation {}

/// User interface representation of state machine states.
abstract class Creator<E> extends Presentation {
  Creator({this.event});
  E? event;
}

/// Use this class to indicate for [HismaRouterDelegateOld] that when machine
/// arrives to this state the user interface shall not be updated (e.g this
/// state is transitional, only does some service invocation or computing).
/// It is a better approach than silent no-update on UI if a state is not
/// defined in the creator map of [HismaRouterDelegateOld]. This way we get
/// assertion failed in case the machine gets to a state that is not defined in
/// the creator list. Alternative is using an [InternalTransition].
class NoUIChange extends Presentation {}

//-----------------------------------------------------------------------------

/// Eliminates redundancy of giving stateId twice when defining creator maps
/// (mapping) of [HismaRouterGenerator]. With the help of this class
/// [HismaRouterDelegateOld] will call the [create] function with a given state.
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

class MaterialPageCreator<E, R> extends PageCreator<E, R> {
  // TODO: should the event be required here if overlay = true?
  // YES, it should be mandatory, otherwise when Flutter pops when
  // user clicks on AppBar BackButton the ui changes, but state remain
  // resulting inconsistent UI. Right now we handle it with an assert.
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
  return MaterialPage<R>(
    child: widget,
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

//------------------------------------------------------------------------------

typedef Close<T> = void Function([T? result]);

abstract class ImperativeCreator<E, R> extends Creator<E> {
  ImperativeCreator({super.event});
  bool _opened = false;
  Future<R?> open(
    BuildContext? context,
    NavigationMachine<dynamic, E, dynamic> machine,
    E fireEvent,
    dynamic fireArg,
  );
  void close([R? result]);
}

class PagelessCreator<E, R> extends ImperativeCreator<E, R> {
  PagelessCreator({
    required this.present,
    required this.rootNavigator,
    super.event,
  });
  Future<R?> Function({
    required BuildContext context,
    required bool rootNavigator,
    required Close<R> close,
    required NavigationMachine<dynamic, E, dynamic> machine,
    required E fireEvent,
    required dynamic fireArg,
  }) present;
  bool rootNavigator;

  late NavigatorState _navigatorState;

  @override
  void close([R? result]) {
    if (_opened) _navigatorState.pop(result);
  }

  // Flutter Navigation does not complete pageless routes created in child
  // navigators when their page they belong to is removed but it silently
  // removes them from the navigator. This is why we shall explicitly set these
  // pageless as closed here (as we can not rely that the functions that created
  // them e.g. showDialog will complete).
  void setClosed() {
    _opened = false;
  }

  @override
  Future<R?> open(
    BuildContext? context,
    NavigationMachine<dynamic, E, dynamic> machine2,
    E fireEvent,
    dynamic fireArg,
  ) async {
    assert(
      !_opened,
      'We shall not call open on this object if it was already opened '
      'and not yet closed.',
    );
    assert(context != null);
    if (context != null) {
      _navigatorState = Navigator.of(context, rootNavigator: rootNavigator);
    }

    _opened = true;
    final result = await present(
      context: context ?? _navigatorState.context,
      rootNavigator: rootNavigator,
      close: close,
      machine: machine2,
      fireEvent: fireEvent,
      fireArg: fireArg,
    );
    _opened = false;
    return result;
  }
}

/*
/// Experimental class to manage the modeless BottomSheet created by invoking
/// showBottomSheet. Since modeless UI can not be well represented by a
/// state in a state machine (user can interact with other UI representing
/// other state) the usefulness of this class is questionable.
class BottomSheetCreator<E, R> extends ImperativeCreator<E, R> {
  BottomSheetCreator({
    required this.present,
    super.event,
  });
  PersistentBottomSheetController<R> Function(
    BuildContext? context,
    Close<R> close,
  ) present;

  PersistentBottomSheetController<R>? _persistentSheetController;

  @override
  void close([R? result]) {
    _persistentSheetController?.close();
  }

  @override
  Future<R?> open(
    BuildContext? context,
    NavigationMachine<dynamic, E, dynamic> machine,
  ) async {
    assert(
      !_opened,
      'We shall not call open on this object if it was already opened '
      'and not yet closed.',
    );
    _opened = true;
    _persistentSheetController = present(context, close);
    final result = await _persistentSheetController?.closed;
    _opened = false;
    // if (result == null) return null;
    return result;
  }
}
*/

/// Experimental class to manage the modeless SnackBar created by invoking
/// showSnackBar. Since modeless UI can not be well represented by a
/// state in a state machine (user can interact with other UI representing
/// other state) the usefulness of this class is questionable.
class SnackBarCreator<E> extends ImperativeCreator<E, SnackBarClosedReason> {
  SnackBarCreator({required this.present, super.event});

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
    BuildContext? context,
    ScaffoldMessengerState scaffoldMessengerState,
    Close<SnackBarClosedReason> close,
  ) present;
  late ScaffoldMessengerState _scaffoldMessengerState;

  @override
  void close([SnackBarClosedReason? result]) {
    _scaffoldMessengerState.hideCurrentSnackBar();
  }

  @override
  Future<SnackBarClosedReason?> open(
    BuildContext? context,
    NavigationMachine<dynamic, E, dynamic> machine,
    E fireEvent,
    dynamic fireArg,
  ) async {
    assert(
      !_opened,
      'We shall not call open on this object if it was already opened '
      'and not yet closed.',
    );
    _opened = true;
    assert(context != null);
    _scaffoldMessengerState = ScaffoldMessenger.of(context!);
    final scaffoldFeatureController =
        present(context, _scaffoldMessengerState, close);
    final reason = await scaffoldFeatureController.closed;
    _opened = false;
    return reason;
  }
}
