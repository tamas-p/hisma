import 'package:hisma/hisma.dart';
import 'package:hisma/src/assistance.dart';
import 'package:test/test.dart';

const plantumlTestName = 'plantuml_test';
final _log = getLogger(plantumlTestName);

enum SID { s1, s2 }

enum EID { e1, e2 }

enum TID { t1, t2 }

void main() {
  late StateMachine<SID, EID, TID> sm;
  setUp(() {
    sm = StateMachine<SID, EID, TID>(
      name: 'sm1',
      initialStateId: SID.s1,
      states: {
        SID.s1: State(),
      },
      transitions: {},
    );
    sm.start();
  });

  group('PlantUML visualizer tests.', () {
    test('Visualize a simple state machine.', () {
      _log.info('Do we need this test?');
    });
  });
}
