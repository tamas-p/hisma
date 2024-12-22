import 'package:flutter/widgets.dart';

import 'hisma_router_generator.dart';

/// Placeholder to implement Hisma route information parser later.
class HismaRouteInformationParser<S, E> extends RouteInformationParser<S> {
  HismaRouteInformationParser(this.routerGenerator);

  final HismaRouterGenerator<S, E> routerGenerator;

  @override
  Future<S> parseRouteInformation(RouteInformation routeInformation) async {
    return routerGenerator.machine.initialStateId;
  }

  @override
  RouteInformation? restoreRouteInformation(S configuration) {
    return RouteInformation(
      location: '/${routerGenerator.machine.name}-$configuration',
    );
  }
}
