import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../hisma_flutter.dart';
import 'assistance.dart';

/// @startuml
/// abstract class Presentation
/// abstract class Creator<E> {
///   E? event
/// }
/// class NoUIChange
/// abstract class PageCreator<T, S, E> {
///   Widget widget
///   bool overlay
///   Page<T> Function({required Widget widget, required S state,}) create
/// }
/// class MaterialPageCreator<T, S, E>
/// class CupertinoPageCreator<T, S, E>
/// abstract class PagelessCreator<T, E> {
///   Future<T?> open(BuildContext context)
///   void close([T? value])
/// }
/// class DialogCreator<T, E> {
///   final bool useRootNavigator;
///   final Future<T?> Function(DialogCreator<T, E> dc, BuildContext context) show;
/// }
///
/// Presentation <|-- NoUIChange
/// Presentation <|-- Creator
/// Creator <|-- PageCreator
/// Creator <|-- PagelessCreator
/// PageCreator <|-- MaterialPageCreator
/// PageCreator <|-- CupertinoPageCreator
/// PagelessCreator <|-- DialogCreator
/// @enduml

final Logger _log = Logger('creator');

/// Abstract class for representing the state of the state machine.
abstract class Presentation {}

/// User interface representation of the state of the state machine.
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
///
class NoUIChange extends Presentation {}

//-----------------------------------------------------------------------------

/// Eliminates redundancy of giving stateId twice when defining creator maps
/// (mapping) of [HismaRouterGenerator]. With the help of this class
/// [HismaRouterDelegate] will call the [create] function with a given state.
abstract class PageCreator<T, S, E> extends Creator<E> {
  PageCreator({
    required this.widget,
    required this.create,
    this.overlay = false,
    super.event,
  });
  final Widget widget;
  final Page<T> Function({
    required Widget widget,
    required String name,
  }) create;
  final bool overlay;
}

abstract class PagelessCreator<T, E> extends Creator<E> {
  PagelessCreator({required super.event});

  Future<T?> open(BuildContext context);
  void close([T? value]);
}

class DialogCreator<T, E> extends PagelessCreator<T, E> {
  DialogCreator({
    required this.show,
    required super.event,
    required this.useRootNavigator,
  });

  final bool useRootNavigator;
  final Future<T?> Function(DialogCreator<T, E> dc, BuildContext context) show;
  BuildContext? _context;

  @override
  Future<T?> open(BuildContext context) {
    _context = context;
    return show(this, context);
  }

  @override
  void close([T? value]) {
    final context = _context;
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

Page<T> _createPage<T, S>({
  required Widget widget,
  required String name,
}) {
  // print('__createPage: $name');
  return MaterialPage<T>(
    child: widget,

    // TODO: consider using path as defined in state machine hierarchy.
    key: ValueKey(name),
    name: name,
  );
}

class MaterialPageCreator<T, S, E> extends PageCreator<T, S, E> {
  // TODO: should the event be required here if overlay = true?
  // YES, it should be mandatory, otherwise when Flutter pops when
  // user clicks on AppBar BackButton the ui changes, but state remain
  // resulting inconsistent UI.
  MaterialPageCreator({
    required super.widget,
    super.overlay,
    super.event,
  }) : super(create: _createPage<T, S>);
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
