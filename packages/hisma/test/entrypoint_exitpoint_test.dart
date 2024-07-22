import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/others/entrypoint_exitpoint.dart';

class ES {
  ES(this.event, this.expected);
  final E event;
  final S expected;
}

class MachineTester {
  MachineTester(this.root);
  final StateMachine<S, E, T> root;

  Future<void> startCheck(S expected) async {
    await root.start();
    expect(root.activeStateId, equals(expected));
  }

  Future<void> check(String name, E event, List<dynamic> expected) async {
    await root.find<S, E, T>(name).fire(event);
    // print(root.getActiveStateRecursive());
    expect(root.getActiveStateRecursive(), equals(expected));
  }
}

void main() {
  group('EntryPoint test', () {
    setUp(
      () async {
        // print('setUp is called.');
      },
    );
    test('Base machine', () async {
      const base = 'base';
      final mt = MachineTester(createMachine(name: base));
      await mt.startCheck(S.a);
      await mt.check(base, E.next, [S.b]);

      await mt.check(base, E.next, [S.c]);
      await mt.check(base, E.next, [S.a]);
      await mt.check(base, E.inside, [S.b]);

      await mt.check(base, E.next, [S.c]);
      await mt.check(base, E.next, [S.a]);
      await mt.check(base, E.finish, [S.b]);

      await mt.check(base, E.next, [S.c]);
      await mt.check(base, E.next, [S.a]);
      await mt.check(base, E.exit, [S.b]);

      await mt.check(base, E.next, [S.c]);
      await mt.check(base, E.next, [S.a]);
      await mt.check(base, E.deep, [S.b]);

      await mt.check(base, E.next, [S.c]);
      await mt.check(base, E.done, []);
    });
  });

  test('Hierarchical machine', () async {
    const l0 = 'l0';
    const l1 = 'l1';
    const l2 = 'l2';
    const l3 = 'l3';

    final m = createMachine(
      name: l0,
      child: createMachine(
        name: l1,
        child: createMachine(
          name: l2,
          child: createMachine(
            name: l3,
          ),
        ),
      ),
    );
    final mt = MachineTester(m);
    await mt.startCheck(S.a);

    await mt.check(l0, E.next, [
      S.b,
      [S.a],
    ]);

    await mt.check(l1, E.next, [
      S.b,
      [
        S.b,
        [S.a],
      ]
    ]);

    await mt.check(l2, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.a],
        ]
      ]
    ]);

    await mt.check(l3, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.b],
        ]
      ]
    ]);

    await mt.check(l3, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.c],
        ]
      ]
    ]);

    await mt.check(l3, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.a],
        ]
      ]
    ]);

    await mt.check(l3, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.b],
        ]
      ]
    ]);

    await mt.check(l3, E.next, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.c],
        ]
      ]
    ]);

    await mt.check(l3, E.done, [
      S.b,
      [
        S.b,
        [S.b],
      ]
    ]);

    await mt.check(l2, E.next, [
      S.b,
      [
        S.b,
        [S.c],
      ]
    ]);

    await mt.check(l2, E.done, [
      S.b,
      [S.b],
    ]);

    await mt.check(l1, E.next, [
      S.b,
      [S.c],
    ]);

    await mt.check(l1, E.done, [S.b]);

    await mt.check(l0, E.next, [S.c]);
    await mt.check(l0, E.next, [S.a]);

    // Let's use ep1
    await mt.check(l0, E.inside, [
      S.b,
      [
        S.b,
        [S.a],
      ]
    ]);

    await mt.check(l2, E.inside, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.b],
        ]
      ]
    ]);

    await mt.check(l0, E.next, [S.c]);
    await mt.check(l0, E.next, [S.a]);

    // Let's use ep2

    await mt.check(l0, E.deep, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.b],
        ]
      ]
    ]);

    await mt.check(l0, E.next, [S.c]);
    await mt.check(l0, E.next, [S.a]);

    // Let's use ep3

    await mt.check(l0, E.finish, [S.b]);

    await mt.check(l0, E.next, [S.c]);
    await mt.check(l0, E.next, [S.a]);

    // Let's use ep4

    await mt.check(l0, E.exit, [S.c]);

    await mt.check(l0, E.next, [S.a]);
    await mt.check(l0, E.next, [
      S.b,
      [S.a],
    ]);

    // Let's use ep2 at l1 level
    await mt.check(l1, E.deep, [
      S.b,
      [
        S.b,
        [
          S.b,
          [S.b],
        ]
      ]
    ]);
  });
}
