import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

void main() {
  group('Hierarchical Action tests', () {
    test(
      'Hierarchical action test - child onExit timing',
      () async {
        // Machine.monitorCreators = [
        //   (m) => VisualMonitor(m),
        // ];

        var value = 50;
        final parentMachine = createHierarchicalMachine(value);
        final childMachine = parentMachine.find<CS, CE, CT>('child');

        expect((parentMachine.data as IntWrapper).value, value);
        await parentMachine.start();
        expect(parentMachine.activeStateId, S.a);

        // After starting, S.a onEntry executes (value * 2)
        value = value * 2; // S.a onEntry
        expect((parentMachine.data as IntWrapper).value, value);

        // Child machine should be in S.CA state
        expect(childMachine.activeStateId, CS.ca);

        // Now fire E.inc to transition from S.a to S.b
        await parentMachine.fire(E.inc);

        // Expected execution order:
        // 1. T.toB guard executes (value + 100)
        value = value + 100; // T.toB guard

        // 2. Child machine S.CA onExit executes (value * 10)
        value = value * 10; // Child S.CA onExit

        // 3. S.a onExit executes (value ~/ 2)
        value = value ~/ 2; // S.a onExit

        // 4. T.toB onAction executes (value + 2)
        value = value + 2; // T.toB onAction

        expect((parentMachine.data as IntWrapper).value, value);
        expect(parentMachine.activeStateId, S.b);

        // Child machine should be stopped since parent moved to S.b
        expect(childMachine.activeStateId, null);
      },
    );
  });
}

enum S { a, b }

enum E { inc, dec }

enum T { toA, toB }

// Child machine enums
enum CS { ca, cb }

enum CE { childEvent }

enum CT { childTransition }

Machine<S, E, T> createHierarchicalMachine(int initial) {
  final myInt = IntWrapper(initial);
  // Create child machine
  final childMachine = Machine<CS, CE, CT>(
    name: 'child',
    initialStateId: CS.ca,
    states: {
      CS.ca: State(
        etm: {
          CE.childEvent: [CT.childTransition],
        },
        onExit: Action(
          description: 'child CA exit - multiply by 10',
          action: (machine, arg) {
            myInt.value = myInt.value * 10;
          },
        ),
      ),
      CS.cb: State(
        etm: {},
      ),
    },
    transitions: {
      CT.childTransition: Transition(to: CS.cb),
    },
  );

  final parentMachine = Machine<S, E, T>(
    name: 'parent',
    data: myInt,
    initialStateId: S.a,
    states: {
      S.a: State(
        etm: {
          E.inc: [T.toB],
        },
        onEntry: Action(
          description: 'double',
          action: (machine, arg) {
            myInt.value = myInt.value * 2;
          },
        ),
        onExit: Action(
          description: 'half',
          action: (machine, arg) {
            myInt.value = myInt.value ~/ 2;
          },
        ),
        regions: [
          Region(machine: childMachine),
        ],
      ),
      S.b: State(
        etm: {
          E.dec: [T.toA],
        },
      ),
    },
    transitions: {
      T.toA: Transition(to: S.a),
      T.toB: Transition(
        to: S.b,
        guard: Guard(
          description: 'Add 100',
          condition: (machine, arg) {
            myInt.value = myInt.value + 100;
            return true;
          },
        ),
        onAction: Action(
          description: 'increase',
          action: (machine, arg) {
            myInt.value = myInt.value + 2;
          },
        ),
      ),
    },
  );

  return parentMachine;
}

class IntWrapper {
  IntWrapper(this.value);
  int value;
}
