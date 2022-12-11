// ignore_for_file: avoid_print

import 'package:hisma/hisma.dart';
import 'package:hisma_console_monitor/hisma_console_monitor.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  late StateMachine<L1S, L1E, L1T> mL1;
  late StateMachine<L2AS, L2AE, L2AT> mL2A;

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
      // print(sm.getActiveState());
      // print(pretty(sm.getActiveState()));
      final expected1 = [
        L1S.s2,
        [
          L2AS.s1,
          [L3AS.s1],
          [L3BS.s1]
        ],
        [
          L2BS.s1,
          [L3CS.s1],
          [L3DS.s1]
        ],
        [
          L2CS.s1,
          [L3ES.s1],
          [L3FS.s1]
        ]
      ];

      print(mL1.getActiveStateRecursive());
      print(pretty(mL1.getActiveStateRecursive()));

      // await mL1.fire(L1_EID.e1);
      await fireAndCheck(mL1, L1E.e1, expected1);

      print(mL1.getActiveStateRecursive());
      print(pretty(mL1.getActiveStateRecursive()));
    });

    test('Simple state check 2.', () async {
      await expectLater(
        mL1.start(),
        completion(equals(null)),
      );
      expect(mL1.getActiveStateRecursive(), equals([L1S.s1]));
    });
  });
}
