import 'package:flutter/material.dart';

import 'assistance.dart';

abstract class Creator {}

/// Use this class to indicate for [HismaRouterDelegate] that when machine
/// arrives to this state the user interface shall not be updated (e.g this
/// state is transitional, only does some service invocation or computing).
/// It is a better approach than silent no-update on UI if a state is not
/// defined in the creator map of [HismaRouterDelegate]. This way we get
/// assertion failed in case the machine gets to a state that is not defined in
/// the creator list.
class NoUIChange extends Creator {}

//-----------------------------------------------------------------------------

abstract class PageCreator<T, S> extends Creator {
  PageCreator({
    required this.widget,
    required this.create,
  });
  final Widget widget;
  final Page<T> Function({
    required Widget widget,
    required S state,
  }) create;
}

abstract class OverlayPageCreator<T, S, E> extends PageCreator<T, S> {
  OverlayPageCreator({
    required super.widget,
    required super.create,
    required this.event,
  });

  final E event;
}

//-----------------------------------------------------------------------------

class MyMaterialPage<W> extends MaterialPage<W> {
  const MyMaterialPage({
    required super.child,
    super.key,
    super.name,
  });

  static final _log = getLogger('$MyMaterialPage');

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

class PagelessCreator<E, T> extends Creator {
  PagelessCreator({
    required this.show,
    required this.event,
    this.rootNavigator = true,
  });
  final Future<T> Function(BuildContext context) show;

  /// If the [show] function instructs using or not using the root navigator
  /// we shall have this information for the given to the creator as well to
  /// let know the [HismaRouterDelegate] that needs this in some cases.
  /// This seems redundant, but I have not yet found a way to eliminate this
  /// redundancy and it does the job.
  final bool rootNavigator;

  final E event;
}

Page<Widget> _doit<S>({
  required Widget widget,
  required S state,
}) {
  return MyMaterialPage<Widget>(
    child: widget,
    key: ValueKey(state),
    name: state.toString(),
  );
}

class MaterialPageCreator<S> extends PageCreator<Widget, S> {
  MaterialPageCreator({
    required super.widget,
  }) : super(create: _doit);
}

class OverlayMaterialPageCreator<S, E>
    extends OverlayPageCreator<Widget, S, E> {
  OverlayMaterialPageCreator({
    required super.widget,
    required super.event,
  }) : super(create: _doit);
}
