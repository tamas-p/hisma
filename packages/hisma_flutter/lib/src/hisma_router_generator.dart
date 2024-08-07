import 'package:flutter/widgets.dart';

import 'creator.dart';
import 'hisma_pageless_handler.dart';
import 'hisma_route_information_parser.dart';
import 'hisma_router_delegate.dart';
import 'hisma_router_delegate_new.dart';
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

  late final RouterDelegate<S> _routerDelegate = HismaRouterDelegateNew<S, E>(
    machine: machine,
    mapping: mapping,
  );

  // late final HismaPagelessHandler<S, E> _pagelessHandler =
  //     HismaPagelessHandler(machine, mapping);

  RouteInformationParser<S> get routeInformationParser =>
      _routeInformationParser;
  RouterDelegate<S> get routerDelegate => _routerDelegate;

  // HismaPagelessHandler<S, E> get pagelessHandler => _pagelessHandler;
}
