// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'assistance.dart';
// import 'creator.dart';
// import 'state_machine_with_change_notifier.dart';

// typedef PageMap<S> = Map<S, Page<dynamic>>;

// class HismaRouterDelegateNoPop<S, W, E> extends RouterDelegate<S>
//     with ChangeNotifier {
//   HismaRouterDelegateNoPop(this._machine, this._creators) {
//     _machine.addListener(notifyListeners);
//   }

//   final _log = getLogger('$HismaRouterDelegateNoPop');

//   final StateMachineWithChangeNotifier<S, E, dynamic> _machine;
//   final Map<S, Creator> _creators;
//   final PageMap<S> _pageMap = {};

//   @override
//   Widget build(BuildContext context) {
//     _log.info('machine: ${_machine.name}, state: ${_machine.activeStateId}');

//     final state = _machine.activeStateId;
//     if (state != null) {
//       if (!_removeCircle(state)) {
//         _processState(state);
//       }
//     }
//     _log.fine('pages: $_pageMap');
//     return _getNavigator();
//   }

//   @override
//   Future<bool> popRoute() {
//     // TODO: We shall allow exit from the app here by returning false.
//     _log.info('popRoute');
//     return SynchronousFuture<bool>(true);
//   }

//   @override
//   Future<void> setNewRoutePath(S configuration) async {
//     // TODO: implement setNewRoutePath
//   }

//   void _processState(S state) {
//     final creator = _creators[state];
//     if (creator == null) throw ArgumentError('$state : ${_machine.name}.');

//     if (creator is PageCreator<W, S> &&
//         creator is! OverlayPageCreator<W, S, E>) {
//       _pageMap.clear();
//       _pageMap[state] = creator.create(state: state, widget: creator.widget);
//     } else {
//       if (creator is OverlayPageCreator<W, S, E>) {
//         _pageMap[state] = creator.create(state: state, widget: creator.widget);
//       } else if (creator is PagelessCreatorOld<E, dynamic>) {
//         _addPageless(state, creator);
//       } else if (creator is NoUIChange) {
//         // No update
//       } else {
//         throw ArgumentError('Missing $state : ${creator.runtimeType}');
//       }
//     }
//   }

//   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
//   Widget _getNavigator() {
//     return Navigator(
//       key: _navigatorKey,
//       pages: _pageMap.values.toList(),
//       onPopPage: (route, dynamic result) {
//         _log.info('Navigator.onPopPage($route, $result)');
//         _log.info('${route.settings.name}');
//         final creator = _creators[_machine.activeStateId];
//         if (creator is OverlayPageCreator<W, S, E>) {
//           Future.delayed(
//             Duration.zero,
//             () {
//               _machine.fire(creator.event, arg: result);
//             },
//           );
//         } else {
//           // throw AssertionError(
//           //   'It must be here an OverlayPageCreator, but it was $creator',
//           // );
//         }
//         // }

//         if (route.didPop(result)) return true;
//         return false;
//       },
//     );
//   }

//   bool _removeCircle(S state) {
//     var flag = false;
//     _pageMap.removeWhere((key, value) {
//       final ret = flag;
//       if (key == state) flag = true;
//       return ret;
//     });
//     return flag;
//   }

//   int test() {
//     String? hello;

//     print(hello?.length);

//     return 2;
//   }

//   Page<W> _createPageWithFunction(
//     S lastPageState,
//     PageCreator<W, S> lastPageCreator,
//     PagelessCreatorOld<E, dynamic> pagelessCreator,
//     S state,
//   ) {
//     return lastPageCreator.create(
//       state: lastPageState,
//       widget: Builder(
//         builder: (context) {
//           /// We schedule execution of function 'f' during next build cycle.
//           Future.delayed(Duration.zero, () async {
//             if (_machine.activeStateId == state) {
//               final dynamic result = await pagelessCreator.show(context);
//               // Only fire if we are still in the state we were created.
//               // It avoids unwanted fire() in case we got here by a fire().
//               if (_machine.activeStateId == state) {
//                 await _machine.fire(pagelessCreator.event, arg: result);
//               }
//             }
//           });

//           return lastPageCreator.widget;
//         },
//       ),
//     );
//   }

//   void _addPageless(
//     S state,
//     PagelessCreatorOld<E, dynamic> creator,
//   ) {
//     if (_pageMap.isEmpty) throw ArgumentError('Empty _pageMap');
//     final lastPageState = _pageMap.entries.last.key;
//     final lastPageCreator = _creators[lastPageState];
//     if (lastPageCreator == null) throw ArgumentError('oldCreator is null.');
//     if (lastPageCreator is! PageCreator<W, S>) throw ArgumentError();
//     final newPage = _createPageWithFunction(
//       lastPageState,
//       lastPageCreator,
//       creator,
//       state,
//     );
//     _pageMap[lastPageState] = newPage;
//   }
// }
