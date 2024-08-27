import 'package:flutter/widgets.dart';

import 'hisma_router_generator.dart';

class HismaRouteInformationParser<S, E> extends RouteInformationParser<S> {
  HismaRouteInformationParser(this.myRouter) {
    print('HismaRouteInformationParser($myRouter)');
  }

  final HismaRouterGenerator<S, E> myRouter;

  @override
  Future<S> parseRouteInformation(RouteInformation routeInformation) async {
    print('parseRouteInformation(${routeInformation.location})');
    return myRouter.machine.initialStateId;
  }

  @override
  RouteInformation? restoreRouteInformation(S configuration) {
    print('root restoreRouteInformation: $configuration');
    return RouteInformation(
      location: '/${myRouter.machine.name}-$configuration',
    );
  }
}
