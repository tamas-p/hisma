import 'package:flutter/widgets.dart';

import 'creator.dart';
import 'hisma_route_information_parser.dart';
import 'hisma_router_delegate.dart';
import 'navigation_machine.dart';

class HismaRouterGenerator<S, E> {
  HismaRouterGenerator({
    required this.machine,
    required this.mapping,
  });
  final NavigationMachine<S, E, dynamic> machine;
  final Map<S, Presentation> mapping;

  late final RouteInformationParser<S> _routeInformationParser =
      HismaRouteInformationParser<S, E>(this);

  late final HismaRouterDelegate<S, E> _routerDelegate =
      HismaRouterDelegate<S, E>(
    machine: machine,
    mapping: mapping,
  );

  RouteInformationParser<S> get routeInformationParser =>
      _routeInformationParser;
  HismaRouterDelegate<S, E> get routerDelegate => _routerDelegate;
}
