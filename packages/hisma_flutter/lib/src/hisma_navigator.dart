// import 'package:flutter/widgets.dart';

// import 'assistance.dart';
// import 'creator.dart';
// import 'hisma_router_generator.dart';

// class HismaNavigator<S, W, E> extends Navigator {
//   HismaNavigator({
//     required HismaRouterGenerator<S, W, E> myRouter,
//     required super.pages,
//     required super.key,
//     required Set<String> shown,
//   }) : super(
//           // [
//           //   if (myRouter.stateUIs[myRouter.machine.activeStateId] != null)
//           //     myRouter.stateUIs[myRouter.machine.activeStateId]!
//           //         .create(myRouter.machine.activeStateId)
//           // ],
//           onPopPage: (route, dynamic result) {
//             _log.info('MyNavigator.onPopPage($route, $result)');
//             _log.info('${route.settings.name}');
//             final fromState = route.settings.name;
//             shown.remove(fromState);
//             final currentState = myRouter.machine.activeStateId.toString();
//             if (fromState == currentState) {
//               final machine = myRouter.machine;
//               final creator = myRouter.mapping[machine.activeStateId];
//               if (creator is OverlayPageCreator<W, S, E>) {
//                 machine.fire(creator.event, arg: result);
//               } else {
//                 assert(
//                   false,
//                   'It must be here an OverlayPageCreator, but it was $creator',
//                 );
//               }
//             }

//             return route.didPop(result);
//           },
//         );

//   static final _log = getLogger('$HismaNavigator');
// }
