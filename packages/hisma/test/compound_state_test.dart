import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:test/test.dart';

import '../example/others/entrypoint_exitpoint.dart';
import 'util.dart';

const _testName = 'compound_state_test';
final _log = getLogger(_testName);

void main() {
  late Machine<L1S, L1E, L1T> mL1;
  late Machine<L2AS, L2AE, L2AT> mL2A;

  setUp(() {
    mL2A = smL2A(
      smL3A(),
      smL3B(),
    );

    mL1 = smL1(
      mL2A,
      smL2B(
        smL3C(),
        smL3D(),
      ),
      smL2C(
        smL3E(),
        smL3F(),
      ),
    );
  });
  group('Check state.', () {
    test('Simple state check.', () async {
      await expectLater(
        mL1.start(),
        completion(equals(null)),
      );
      expect(mL1.getActiveStateRecursive(), equals([L1S.s1]));
      final expected1 = [
        L1S.s2,
        [
          L2AS.s1,
          [L3AS.s1],
          [L3BS.s1],
        ],
        [
          L2BS.s1,
          [L3CS.s1],
          [L3DS.s1],
        ],
        [
          L2CS.s1,
          [L3ES.s1],
          [L3FS.s1],
        ]
      ];

      _log.finest(mL1.getActiveStateRecursive());
      _log.finest(pretty(mL1.getActiveStateRecursive()));

      // await mL1.fire(L1_EID.e1);
      await fireAndCheck(mL1, L1E.e1, expected1);

      _log.finest(mL1.getActiveStateRecursive());
      _log.finest(pretty(mL1.getActiveStateRecursive()));
    });

    test('Simple state check 2.', () async {
      await expectLater(
        mL1.start(),
        completion(equals(null)),
      );
      expect(mL1.getActiveStateRecursive(), equals([L1S.s1]));
    });
  });

  test('Test parent?.name', () async {
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

    expect(m.find<S, E, T>(l0).activeStateId, equals(null));
    expect(m.find<S, E, T>(l1).activeStateId, equals(null));
    expect(m.find<S, E, T>(l2).activeStateId, equals(null));
    expect(m.find<S, E, T>(l3).activeStateId, equals(null));

    expect(m.find<S, E, T>(l0).parent?.name, equals(null));
    expect(m.find<S, E, T>(l1).parent?.name, equals(l0));
    expect(m.find<S, E, T>(l2).parent?.name, equals(l1));
    expect(m.find<S, E, T>(l3).parent?.name, equals(l2));

    await m.start();
    expect(m.find<S, E, T>(l0).activeStateId, equals(S.a));
    expect(m.find<S, E, T>(l1).activeStateId, equals(null));
    expect(m.find<S, E, T>(l2).activeStateId, equals(null));
    expect(m.find<S, E, T>(l3).activeStateId, equals(null));

    expect(m.find<S, E, T>(l0).parent?.name, equals(null));
    expect(m.find<S, E, T>(l1).parent?.name, equals(l0));
    expect(m.find<S, E, T>(l2).parent?.name, equals(l1));
    expect(m.find<S, E, T>(l3).parent?.name, equals(l2));

    await m.fire(E.deep);
    expect(m.find<S, E, T>(l0).activeStateId, equals(S.b));
    expect(m.find<S, E, T>(l1).activeStateId, equals(S.b));
    expect(m.find<S, E, T>(l2).activeStateId, equals(S.b));
    expect(m.find<S, E, T>(l3).activeStateId, equals(S.b));

    expect(m.find<S, E, T>(l0).parent?.name, equals(null));
    expect(m.find<S, E, T>(l1).parent?.name, equals(l0));
    expect(m.find<S, E, T>(l2).parent?.name, equals(l1));
    expect(m.find<S, E, T>(l3).parent?.name, equals(l2));

    expect(
      m
          .find<S, E, T>(
            m
                    .find<S, E, T>(m.find<S, E, T>(l3).parent?.name ?? '')
                    .parent
                    ?.name ??
                '',
          )
          .parent
          ?.name,
      equals(l0),
    );
  });
}
