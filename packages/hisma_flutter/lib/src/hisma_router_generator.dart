import 'package:flutter/widgets.dart';

import 'creator.dart';
import 'hisma_route_information_parser.dart';
import 'hisma_router_delegate.dart';
import 'state_machine_with_change_notifier.dart';

class HismaRouterGenerator<S, W, E> {
  HismaRouterGenerator({
    required this.machine,
    required this.creators,
  });
  final StateMachineWithChangeNotifier<S, E, dynamic> machine;
  final Map<S, Creator> creators;

  late final RouteInformationParser<S> _routeInformationParser =
      HismaRouteInformationParser<S, W, E>(this);

  late final RouterDelegate<S> _routerDelegate =
      HismaRouterDelegate<S, W, E>(this);

  RouteInformationParser<S> get routeInformationParser =>
      _routeInformationParser;
  RouterDelegate<S> get routerDelegate => _routerDelegate;
}
