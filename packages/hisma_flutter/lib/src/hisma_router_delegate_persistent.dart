// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:hisma/hisma.dart';

// import 'assistance.dart';
// import 'creator.dart';
// import 'state_machine_with_change_notifier.dart';

// typedef PageMap<S> = Map<S, Page<dynamic>>;

// class HismaRouterDelegatePersistent<S, W, E> extends RouterDelegate<S>
//     with ChangeNotifier {
//   HismaRouterDelegatePersistent(this._machine, this._creators) {
//     _machine.addListener(notifyListeners);
//   }

//   final _log = getLogger('$HismaRouterDelegatePersistent');

//   final StateMachineWithChangeNotifier<S, E, dynamic> _machine;
//   final Map<S, Creator> _creators;
//   final PageMap<S> _pageMap = {};

//   @override
//   Widget build(BuildContext context) {
//     _log.info('machine: ${_machine.name}, state: ${_machine.activeStateId}');

//     final state = _machine.activeStateId;
//     if (state != null) {
//       if (!_removeCircleWithPageless(state)) {
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
//         // _pageMap[state] = TestPage<Widget>();
//         // _pageMap[state] = MyPage<Widget, S, E>(
//         //   machine: _machine,
//         //   pagelessCreator: creator,
//         //   state: state,
//         // );
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
//       pages: _pageMap.values
//           .where((page) => page is! PagelessPage<void, S>)
//           .toList(),
//       onPopPage: (route, dynamic result) {
//         _log.info('Navigator.onPopPage($route, $result)');
//         _log.info('${route.settings.name}');
//         final fromState = route.settings.name;
//         final currentState = _machine.activeStateId.toString();
//         // if (fromState == currentState) {
//         final creator = _creators[_machine.activeStateId];
//         if (creator is OverlayPageCreator<W, S, E>) {
//           _machine.fire(creator.event, arg: result);
//           // }
//           // if (creator is OverlayMaterialPageCreator<S, E>) {
//           //   _machine.fire(creator.event, arg: result);
//           // } else if (creator is PagelessCreator<E, dynamic>) {
//           //   _machine.fire(creator.event, arg: result);
//         } else {
//           throw AssertionError(
//             'It must be here an OverlayPageCreator, but it was $creator',
//           );
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

//   bool _removeCircleWithPageless(S state) {
//     if (_pageMap.keys.contains(state)) {
//       while (_pageMap.entries.last.key != state) {
//         final entry = _pageMap.entries.last;
//         final page = entry.value;
//         if (page is PagelessPage<void, S>) {
//           // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//           Future.delayed(Duration.zero, () {
//             final navigatorState = page.navigatorState;
//             if (navigatorState != null) {
//               print('POP with $navigatorState');
//               final creator = _creators[page.state];
//               if (creator is! PagelessCreator<E, dynamic>)
//                 throw AssertionError();
//               // We must pop pageless routes after Navigator.pages update
//               // already happened to avoid popping a paged route here that is
//               // "popped" implicitly by the Navigator.
//               // That is said, but there will be a side effect seeing the
//               // flashing the pageless routes for a fraction of a second.
//               // Navigator.of(context, rootNavigator: creator.rootNavigator).pop();
//               navigatorState.pop();
//             }
//           });
//         }
//         _pageMap.remove(entry.key);
//       }
//       return true;
//     }
//     return false;
//   }

//   Page<W> _createPageWithFunction(
//     S lastPageState,
//     PageCreator<W, S> lastPageCreator,
//     PagelessCreatorOld<E, dynamic> pagelessCreator,
//     PagelessPage<void, S> pagelessPage,
//     S state,
//   ) {
//     return lastPageCreator.create(
//       state: lastPageState,
//       widget: Builder(
//         builder: (context) {
//           /// We schedule execution of function 'f' during next build cycle.
//           // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//           Future.delayed(Duration.zero, () async {
//             // Future.delayed(Duration.zero, () async {
//             if (_machine.activeStateId == state &&
//                 pagelessPage.navigatorState == null) {
//               pagelessPage.navigatorState = Navigator.of(
//                 context,
//                 rootNavigator: pagelessCreator.rootNavigator,
//               );
//               final dynamic result = await pagelessCreator.show(context);
//               print('### popped! ###########################################');
//               pagelessPage.navigatorState = null;
//               // Only fire if we are still in the state we were created.
//               // It avoids unwanted fire() in case we got here by a fire().
//               print('${_machine.activeStateId} == $state');
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
//     final lastPageState = _pageMap.entries
//         .where((entry) => entry.value is! PagelessPage<void, S>)
//         .last
//         .key;

//     final lastPageCreator = _creators[lastPageState];
//     if (lastPageCreator == null) throw ArgumentError('oldCreator is null.');
//     if (lastPageCreator is! PageCreator<W, S>) throw ArgumentError();
//     final pagelessPage = PagelessPage<void, S>(state);
//     final newPage = _createPageWithFunction(
//       lastPageState,
//       lastPageCreator,
//       creator,
//       pagelessPage,
//       state,
//     );
//     _pageMap[lastPageState] = newPage;
//     _pageMap[state] = pagelessPage;
//   }
// }

// class PagelessPage<T, S> extends Page<T> {
//   PagelessPage(this.state);

//   NavigatorState? navigatorState;
//   S state;

//   @override
//   Route<T> createRoute(BuildContext context) {
//     throw UnimplementedError();
//   }
// }

// class TestPage<T> extends Page<T> {
//   @override
//   Route<T> createRoute(BuildContext context) {
//     return TestRoute2<T>(context: context, settings: this);
//   }
// }

// class TestRoute2<T> extends DialogRoute<T> {
//   TestRoute2({required super.context, required this.settings})
//       : super(
//           settings: settings,
//           builder: (context) {
//             return AlertDialog(
//               title: const Text('Exit App'),
//               content: const Text('Are you sure you want to exit the app?'),
//               actions: [
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () => Navigator.pop(context, true),
//                 ),
//                 TextButton(
//                   child: const Text('Confirm'),
//                   onPressed: () => Navigator.pop(context, false),
//                 ),
//               ],
//             );
//           },
//         );
//   @override
//   final TestPage<T> settings;
// }

// class TestRoute<T> extends PopupRoute<T> {
//   TestRoute(this.settings) : super(settings: settings);

//   @override
//   final TestPage<T> settings;

//   @override
//   Color? get barrierColor => null;

//   @override
//   bool get barrierDismissible => true;

//   @override
//   String? get barrierLabel => null;

//   @override
//   Widget buildPage(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//   ) {
//     return AlertDialog(
//       title: const Text('Exit App'),
//       content: const Text('Are you sure you want to exit the app?'),
//       actions: [
//         TextButton(
//           child: const Text('Cancel'),
//           onPressed: () => Navigator.pop(context, true),
//         ),
//         TextButton(
//           child: const Text('Confirm'),
//           onPressed: () => Navigator.pop(context, false),
//         ),
//       ],
//     );
//   }

//   @override
//   Duration get transitionDuration => const Duration(seconds: 1);
// }

// class MyPage<T, S, E> extends Page<T> {
//   const MyPage({
//     required this.machine,
//     required this.pagelessCreator,
//     required this.state,
//   });

//   final StateMachine<dynamic, dynamic, dynamic> machine;
//   final PagelessCreatorOld<E, dynamic> pagelessCreator;
//   final S state;

//   @override
//   Route<T> createRoute(BuildContext context) {
//     // return MaterialPageRoute(
//     //   builder: (context) => Container(),
//     //   settings: this,
//     // );

//     // return DialogRoute(
//     //   context: context,
//     //   builder: (context) => Container(),
//     //   settings: this,
//     //   barrierColor: null,
//     // );

//     return PagelessRoute(this);
//   }
// }

// class PagelessRoute2<T, E, S> extends PageRoute<T> {
//   PagelessRoute2(this.settings) : super(settings: settings);

//   @override
//   final MyPage<T, S, E> settings;

//   @override
//   Color? get barrierColor => null;

//   @override
//   // TODO: implement barrierLabel
//   String? get barrierLabel => null;

//   bool shown = false;

//   @override
//   Widget buildPage(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//   ) {
//     if (!shown) {
//       Future.delayed(Duration.zero, () async {
//         shown = true;
//         final dynamic result = await settings.pagelessCreator.show(context);
//         // Only fire if we are still in the state we were created.
//         // It avoids unwanted fire() in case we got here by a fire().
//         if (settings.machine.activeStateId == settings.state) {
//           await settings.machine
//               .fire(settings.pagelessCreator.event, arg: result);
//         }
//       });
//     }

//     return Container();
//   }

//   @override
//   bool get maintainState => true;

//   @override
//   Duration get transitionDuration => const Duration(seconds: 1);
// }

// class PagelessRoute<T, E, S> extends PopupRoute<T> {
//   PagelessRoute(this.settings) : super(settings: settings);

//   @override
//   bool get maintainState => false;

//   @override
//   final MyPage<T, S, E> settings;

//   @override
//   Color? get barrierColor => null;

//   @override
//   bool get barrierDismissible => true;

//   @override
//   String? get barrierLabel => null;

//   bool shown = false;

//   @override
//   Widget buildPage(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//   ) {
//     return Builder(
//       builder: (context) {
//         if (!shown) {
//           Future.delayed(Duration.zero, () async {
//             shown = true;
//             final dynamic result = await settings.pagelessCreator.show(context);
//             // Only fire if we are still in the state we were created.
//             // It avoids unwanted fire() in case we got here by a fire().
//             if (settings.machine.activeStateId == settings.state) {
//               await settings.machine
//                   .fire(settings.pagelessCreator.event, arg: result);
//             }
//           });
//         }

//         return Container();
//       },
//     );
//   }

//   @override
//   Duration get transitionDuration => const Duration(seconds: 1);
// }

// class MyRoute<T> extends ModalRoute<T> {
//   @override
//   // TODO: implement barrierColor
//   Color? get barrierColor => throw UnimplementedError();

//   @override
//   // TODO: implement barrierDismissible
//   bool get barrierDismissible => throw UnimplementedError();

//   @override
//   // TODO: implement barrierLabel
//   String? get barrierLabel => throw UnimplementedError();

//   @override
//   Widget buildPage(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation) {
//     // TODO: implement buildPage
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement maintainState
//   bool get maintainState => throw UnimplementedError();

//   @override
//   // TODO: implement opaque
//   bool get opaque => throw UnimplementedError();

//   @override
//   // TODO: implement transitionDuration
//   Duration get transitionDuration => throw UnimplementedError();
// }
