import 'package:flutter/widgets.dart';

import 'hisma_router_generator.dart';

class HismaRouteInformationParser<S, W, E> extends RouteInformationParser<S> {
  HismaRouteInformationParser(this.myRouter);
  final HismaRouterGenerator<S, W, E> myRouter;

  @override
  Future<S> parseRouteInformation(RouteInformation routeInformation) async {
    return myRouter.machine.initialStateId;
  }
}
