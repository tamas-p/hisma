import 'package:flutter/widgets.dart';

import 'hisma_router_generator.dart';

class HismaRouteInformationParser<S, E> extends RouteInformationParser<S> {
  HismaRouteInformationParser(this.myRouter);
  final HismaRouterGenerator<S, E> myRouter;

  @override
  Future<S> parseRouteInformation(RouteInformation routeInformation) async {
    return myRouter.machine.initialStateId;
  }
}
