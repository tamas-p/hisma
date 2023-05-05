import 'package:flutter/material.dart';

import '../hisma_flutter.dart';
import 'assistance.dart';
import 'hisma_router_delegate.dart';

/// @startuml
/// class Creator
/// class NoUIChange
/// class PageCreator<T, S>
/// class OverlayPageCreator<T, S, E> {
///  E event
/// }
/// class PagelessCreator<T, E> {
///  E event
/// }
/// class MaterialPageCreator<S>
/// class OverlayMaterialPageCreator<S, E> {
///  E event
/// }
/// class PagelessRouteManager<T>
///
/// Creator <|-- NoUIChange
/// Creator <|-- PageCreator
/// PageCreator <|-- OverlayPageCreator
/// Creator <|-- PagelessCreator
/// PageCreator <|-- MaterialPageCreator
/// OverlayPageCreator <|-- OverlayMaterialPageCreator
/// PagelessRouteManager -* PagelessCreator
/// @enduml
///
///
///
/// abstract class PagelessRouteManager<T> {
///   Future<T?> open(BuildContext context)
///   void close([T? value])
/// }
///
/// That triggers event:
/// - Android back button
/// - Browser back button
/// - PagelessRoute close
/// - Overlay page back button
///
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
/// class MaterialPageCreator<S, E>
/// class CupertinoPageCreator<S, E>
/// abstract class PagelessCreator<T, E> {
///   Future<T?> open(BuildContext context)
///   void close([T? value])
/// }
///
/// Presentation <|-- NoUIChange
/// Presentation <|-- Creator
/// Creator <|-- PageCreator
/// Creator <|-- PagelessCreator
/// PageCreator <|-- MaterialPageCreator
/// PageCreator <|-- CupertinoPageCreator
/// @enduml
/// PagelessRouteManager -* PagelessCreator
/// abstract class OverlayPageCreator<T, S, E>
/// class OverlayMaterialPageCreator<S, E>
/// class OverlayCupertinoPageCreator<S, E>
/// PageCreator <|-- OverlayPageCreator
/// OverlayPageCreator <|-- OverlayMaterialPageCreator
/// OverlayPageCreator <|-- OverlayCupertinoPageCreator

abstract class Presentation {}

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
/// the creator list.
class NoUIChange extends Presentation {}

//-----------------------------------------------------------------------------

/// Eliminates redundancy of giving stateId twice when defining `creators` maps
/// of [HismaRouterGenerator]. With the help of this class [HismaRouterDelegate]
/// will call the [create] function with a given state.
/// Explicit [create] function allows changing create behavior allowing wrapping
/// it with code e.g. doing the pageless routes creation.
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
    required S state,
  }) create;
  final bool overlay;
}

/*
abstract class OverlayPageCreator<T, S, E> extends PageCreator<T, S> {
  OverlayPageCreator({
    required super.widget,
    required super.create,
    required this.event,
  });

  final E event;
}
*/
//-----------------------------------------------------------------------------

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

// abstract class PagelessRouteManager<T> {
//   Future<T?> open(BuildContext context);
//   void close([T? value]);
// }

abstract class PagelessCreator<T, E> extends Creator<E> {
  // TODO: should the event be required here?
  PagelessCreator({super.event});

  Future<T?> open(BuildContext context);
  void close([T? value]);
}

// class PagelessCreatorOld<E, T> extends Creator {
//   PagelessCreatorOld({
//     required this.show,
//     required this.event,
//     this.rootNavigator = true,
//   });
//   final Future<T> Function(
//     BuildContext context, {
//     void Function(BuildContext)? setContext,
//   }) show;

// /// If the [show] function instructs using or not using the root navigator
// /// we shall have this information for the given to the creator as well to
// /// let know the [HismaRouterDelegate] that needs this in some cases.
// /// This seems redundant, but I have not yet found a way to eliminate this
// /// redundancy and it does the job.
// final bool rootNavigator;

// final E event;
// }

Page<Widget> _createPage<S>({
  required Widget widget,
  required S state,
}) {
  print('__createPage: $state');
  return MaterialPage<Widget>(
    child: widget,

    // TODO: consider using path as defined in state machine hierarchy.
    key: ValueKey(state),
    name: state.toString(),
  );
}

class MaterialPageCreator<S, E> extends PageCreator<Widget, S, E> {
  MaterialPageCreator({
    required super.widget,
    super.overlay,
    super.event,
  }) : super(create: _createPage);
}

// class OverlayMaterialPageCreator<S, E>
//     extends OverlayPageCreator<Widget, S, E> {
//   OverlayMaterialPageCreator({
//     required super.widget,
//     required super.event,
//   }) : super(create: _createPage);
// }
