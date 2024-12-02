import 'package:flutter/widgets.dart';

import 'creator.dart';
import 'hisma_route_information_parser.dart';
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

  late final HismaRouterDelegate<S, E> _routerDelegate =
      HismaRouterDelegate<S, E>(
    machine: machine,
    mapping: mapping,
  );

  // late final HismaPagelessHandler<S, E> _pagelessHandler =
  //     HismaPagelessHandler(machine, mapping);

  RouteInformationParser<S> get routeInformationParser =>
      _routeInformationParser;
  HismaRouterDelegate<S, E> get routerDelegate => _routerDelegate;

  // HismaPagelessHandler<S, E> get pagelessHandler => _pagelessHandler;
}
