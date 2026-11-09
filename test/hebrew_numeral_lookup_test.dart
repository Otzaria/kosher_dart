import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('allocation-free Hebrew number lookup tables', () {
    test('common years and edge values match established spellings', () {
      final formatter = HebrewDateFormatter();
      final expected = <int, String>{
        0: 'אפס',
        1: 'א׳',
        5: 'ה׳',
        10: 'י׳',
        15: 'ט״ו',
        16: 'ט״ז',
        33: 'ל״ג',
        100: 'ק׳',
        5784: 'תשפ״ד',
      };
      expected.forEach((number, label) {
        expect(formatter.formatHebrewNumber(number), label);
      });
    });

    test('lookup tables cannot leak mutable state across instances', () {
      final first = HebrewDateFormatter();
      final second = HebrewDateFormatter()..useGershGershayim = false;
      for (var n = 1; n <= 999; n++) {
        final a = first.formatHebrewNumber(n);
        expect(a, isNotEmpty);
        expect(second.formatHebrewNumber(n), isNot(contains('״')));
        expect(second.formatHebrewNumber(n), isNot(contains('׳')));
        expect(first.formatHebrewNumber(n), a);
      }
    });
  });
}
