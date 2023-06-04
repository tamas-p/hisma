import 'package:flutter/widgets.dart';

import 'creator.dart';
import 'hisma_route_information_parser.dart';
import 'hisma_router_delegate_no_pop.dart';
import 'hisma_router_delegate_pop.dart';
import 'hisma_router_delegate.dart';
import 'state_machine_with_change_notifier.dart';

class HismaRouterGenerator<S, E> {
  HismaRouterGenerator({
    required this.machine,
    required this.mapping,
  });
  final StateMachineWithChangeNotifier<S, E, dynamic> machine;
  final Map<S, Presentation> mapping;

  late final RouteInformationParser<S> _routeInformationParser =
      HismaRouteInformationParser<S, E>(this);

  // late final RouterDelegate<S> _routerDelegate =
  //     HismaRouterDelegate<S, W, E>(this);

  late final RouterDelegate<S> _routerDelegate =
      HismaRouterDelegatePop<S, E>(machine, mapping);

  // late final RouterDelegate<S> _routerDelegate =
  //     HismaRouterDelegateNoPop<S, W, E>(machine, creators);

  RouteInformationParser<S> get routeInformationParser =>
      _routeInformationParser;
  RouterDelegate<S> get routerDelegate => _routerDelegate;
}
