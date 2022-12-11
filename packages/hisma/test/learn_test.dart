// ignore_for_file: avoid_print

import 'package:test/test.dart';

void main() {
  setUp(() {
    print('SETUP');
  });
  group('Group A', () {
    test('Test 1', () {
      print('A1');
    });
    test('Test 2', () {
      print('A2');
    });
  });

  group('Group B', () {
    test('Test 2', () {
      print('B1');
    });
    test('Test 2', () {
      print('B2');
    });
  });
}
