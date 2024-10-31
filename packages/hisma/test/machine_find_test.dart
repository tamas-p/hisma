import 'package:hisma/hisma.dart';
import 'package:test/test.dart';

import '../example/others/plantuml_example.dart';

void main() {
  group('Machine find test from m1.', () {
    test('Machine find test - Not found.', () {
      expect(
        () => m1.find<dynamic, dynamic, dynamic>('Does not exist'),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
      expect(
        () => m1.find<S, E, T>('Does not exist'),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });

    test('Machine find test - m1.', () {
      expect(
        m1.find<dynamic, dynamic, dynamic>(m1name),
        equals(m1),
      );
      expect(
        m1.find<S, E, T>(m1name),
        equals(m1),
      );
      expect(
        () => m1.find<SS, SE, ST>(m1name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });

    test('Machine find test - m1s1.', () {
      expect(
        m1.find<dynamic, dynamic, dynamic>(m1s1name),
        equals(m1s1),
      );
      expect(
        m1.find<SS, SE, ST>(m1s1name),
        equals(m1s1),
      );
      expect(
        () => m1.find<S, E, T>(m1s1name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });

    test('Machine find test - m1s1s1.', () {
      expect(
        m1.find<dynamic, dynamic, dynamic>(m1s1s1name),
        equals(m1s1s1),
      );
      expect(
        m1.find<SSS0, SSE0, SST0>(m1s1s1name),
        equals(m1s1s1),
      );
      expect(
        () => m1.find<S, E, T>(m1s1s1name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });
  });
  test('Machine find test - m1s2.', () {
    expect(
      m1.find<dynamic, dynamic, dynamic>(m1s2name),
      equals(m1s2),
    );
    expect(
      m1.find<SS2, SE2, ST2>(m1s2name),
      equals(m1s2),
    );
    expect(
      () => m1.find<S, E, T>(m1s2name),
      throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
    );
  });

  test('Machine find test - m1s2s1.', () {
    expect(
      m1.find<dynamic, dynamic, dynamic>(m1s2s1name),
      equals(m1s2s1),
    );
    expect(
      m1.find<SSS1, SSE1, SST1>(m1s2s1name),
      equals(m1s2s1),
    );
    expect(
      () => m1.find<S, E, T>(m1s2s1name),
      throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
    );
  });

  test('Machine find test - m1s2s2.', () {
    expect(
      m1.find<dynamic, dynamic, dynamic>(m1s2s2name),
      equals(m1s2s2),
    );
    expect(
      m1.find<SSS2, SSE2, SST2>(m1s2s2name),
      equals(m1s2s2),
    );
    expect(
      () => m1.find<S, E, T>(m1s2s2name),
      throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
    );
  });
  test('Machine find test - m1s2s1.', () {
    expect(
      m1.find<dynamic, dynamic, dynamic>(m1s2s3name),
      equals(m1s2s3),
    );
    expect(
      m1.find<SSS3, SSE3, SST3>(m1s2s3name),
      equals(m1s2s3),
    );
    expect(
      () => m1.find<S, E, T>(m1s2s3name),
      throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
    );
  });

  group('Machine find test from m1s2.', () {
    test('Find test from m1s2 - itself.', () {
      expect(
        m1s2s2.find<dynamic, dynamic, dynamic>(m1s2s2name),
        equals(m1s2s2),
      );
      expect(
        m1s2s2.find<SSS2, SSE2, SST2>(m1s2s2name),
        equals(m1s2s2),
      );
      expect(
        () => m1s2s2.find<S, E, T>(m1s2s2name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });
    test('Find test from m1s2 - find parent.', () {
      expect(
        () => m1s2s2.find<dynamic, dynamic, dynamic>(m1s2name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
      expect(
        () => m1s2s2.find<dynamic, dynamic, dynamic>(m1name),
        throwsA(const TypeMatcher<HismaMachineNotFoundException>()),
      );
    });
  });
}
