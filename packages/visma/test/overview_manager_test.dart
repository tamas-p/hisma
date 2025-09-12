import 'package:test/test.dart';
import 'package:visma/src/visualizer/visual_monitor/server/overview_manager.dart';
import 'package:visma/src/visualizer/visual_monitor/server/statemachine_manager.dart';

// TODO: Extend testing with hostname & domain.
void main() {
  group(
    'OverviewManager',
    () {
      test('Rendering hierarchical state machines to PlantUML, ordered. ', () {
        final overviewManager = OverviewManager();
        add(overviewManager, smId: 'SM 1', parentSmId: null);
        add(overviewManager, smId: 'SM 1.1', parentSmId: 'SM 1');
        add(overviewManager, smId: 'SM 1.2', parentSmId: 'SM 1');
        add(overviewManager, smId: 'SM 1.2.1', parentSmId: 'SM 1.2');
        add(overviewManager, smId: 'SM 1.2.2', parentSmId: 'SM 1.2');
        add(overviewManager, smId: 'SM 1.2.3', parentSmId: 'SM 1.2');
        add(overviewManager, smId: 'SM 2', parentSmId: null);
        add(overviewManager, smId: 'SM 2.1', parentSmId: 'SM 2');
        add(overviewManager, smId: 'SM 2.2', parentSmId: 'SM 2');
        add(overviewManager, smId: 'SM 2.3', parentSmId: 'SM 2');
        add(overviewManager, smId: 'SM 2.4', parentSmId: 'SM 2');
        add(overviewManager, smId: 'SM 3', parentSmId: null);
        add(overviewManager, smId: 'SM 3.1', parentSmId: 'SM 3');
        add(overviewManager, smId: 'SM 3.1.1', parentSmId: 'SM 3');
        add(overviewManager, smId: 'SM 3.1.2', parentSmId: 'SM 3');
        add(overviewManager, smId: 'SM 3.1.3', parentSmId: 'SM 3');
        add(overviewManager, smId: 'SM 3.1.4', parentSmId: 'SM 3');
        final res = overviewManager.render();
        expect(res, equals(_expected));
      });
      test(
        'Rendering hierarchical state machines to PlantUML, random.',
        () {
          final overviewManager = OverviewManager();
          add(overviewManager, smId: 'SM 1.2', parentSmId: 'SM 1');
          add(overviewManager, smId: 'SM 2', parentSmId: null);
          add(overviewManager, smId: 'SM 2.2', parentSmId: 'SM 2');
          add(overviewManager, smId: 'SM 1.2.1', parentSmId: 'SM 1.2');
          add(overviewManager, smId: 'SM 1.2.3', parentSmId: 'SM 1.2');
          add(overviewManager, smId: 'SM 3.1.4', parentSmId: 'SM 3');
          add(overviewManager, smId: 'SM 2.1', parentSmId: 'SM 2');
          add(overviewManager, smId: 'SM 2.3', parentSmId: 'SM 2');
          add(overviewManager, smId: 'SM 3.1.2', parentSmId: 'SM 3');
          add(overviewManager, smId: 'SM 2.4', parentSmId: 'SM 2');
          add(overviewManager, smId: 'SM 1.1', parentSmId: 'SM 1');
          add(overviewManager, smId: 'SM 1', parentSmId: null);
          add(overviewManager, smId: 'SM 1.2.2', parentSmId: 'SM 1.2');
          add(overviewManager, smId: 'SM 3', parentSmId: null);
          add(overviewManager, smId: 'SM 3.1.3', parentSmId: 'SM 3');
          add(overviewManager, smId: 'SM 3.1', parentSmId: 'SM 3');
          add(overviewManager, smId: 'SM 3.1.1', parentSmId: 'SM 3');
          final res = overviewManager.render();
          // print(res);
          expect(res, equals(_expected));
        },
        // TODO: fix this test
        skip: true,
      );
    },
  );
}

const _expected = '''
@startmindmap State machine hierarchy diagram
<style>
  mindmapDiagram {
    BackgroundColor #18191a  
    LineColor Gray
    node {
      BackgroundColor #18191a
      LineColor Gray
      FontColor Gray
      HyperLinkColor Gray
    }
    :depth(0) {
      BackGroundColor Navy
    }
    :depth(1) {
      BackGroundColor Navy
    }
    :depth(2) {
      BackGroundColor Navy
    }
  }
</style>
* SM Watcher
** host1
*** 111
**** [[/machine/page/host1/111/SM%201 SM 1]]
**** [[/machine/page/host1/111/SM%201.1 SM 1.1]]
**** [[/machine/page/host1/111/SM%201.2 SM 1.2]]
**** [[/machine/page/host1/111/SM%201.2.1 SM 1.2.1]]
**** [[/machine/page/host1/111/SM%201.2.2 SM 1.2.2]]
**** [[/machine/page/host1/111/SM%201.2.3 SM 1.2.3]]
**** [[/machine/page/host1/111/SM%202 SM 2]]
**** [[/machine/page/host1/111/SM%202.1 SM 2.1]]
**** [[/machine/page/host1/111/SM%202.2 SM 2.2]]
**** [[/machine/page/host1/111/SM%202.3 SM 2.3]]
**** [[/machine/page/host1/111/SM%202.4 SM 2.4]]
**** [[/machine/page/host1/111/SM%203 SM 3]]
**** [[/machine/page/host1/111/SM%203.1 SM 3.1]]
**** [[/machine/page/host1/111/SM%203.1.1 SM 3.1.1]]
**** [[/machine/page/host1/111/SM%203.1.2 SM 3.1.2]]
**** [[/machine/page/host1/111/SM%203.1.3 SM 3.1.3]]
**** [[/machine/page/host1/111/SM%203.1.4 SM 3.1.4]]
@endmindmap
''';

void add(
  OverviewManager overviewManager, {
  required String smId,
  required String? parentSmId,
}) {
  final uniqueSmId =
      StateMachineId(hostname: 'host1', domain: '111', smId: smId);
  overviewManager.add(
    uniqueSmId: uniqueSmId,
    children: {},
  );
}
