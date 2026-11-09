import 'package:kosher_dart/kosher_dart.dart';
import 'package:test/test.dart';

void main() {
  group('HebrewDateFormatter patterns', () {
    final gregorian = JewishDate.initDate(
      jewishYear: 5784,
      jewishMonth: JewishDate.SIVAN,
      jewishDayOfMonth: 5,
    );

    test('formats the default date without consuming month-name letters', () {
      final formatter = HebrewDateFormatter();
      expect(formatter.format(gregorian), '5 Sivan 5784');
    });

    test('time token must not replace a within Sivan', () {
      final formatter = HebrewDateFormatter();
      final text = formatter.format(gregorian, pattern: 'MM a');
      expect(text.split(' ').first, 'Sivan');
      expect(text.startsWith('Sivan '), isTrue);
    });

    test('standalone weekday token E is expanded', () {
      final formatter = HebrewDateFormatter()..hebrewFormat = true;
      expect(formatter.format(gregorian, pattern: 'E'),
          formatter.formatDayOfWeek(gregorian));
    });

    test('D is the Hebrew year ordinal, starting at 1 on Rosh Hashana', () {
      final startOfYear = JewishDate.initDate(
        jewishYear: 5784,
        jewishMonth: JewishDate.TISHREI,
        jewishDayOfMonth: 1,
      );
      final formatter = HebrewDateFormatter();
      expect(formatter.format(startOfYear, pattern: 'D'), '1');
      startOfYear.forward();
      expect(formatter.format(startOfYear, pattern: 'D'), '2');
    });

    test('yyy token does not duplicate the preceding year token', () {
      final formatter = HebrewDateFormatter();
      expect(formatter.format(gregorian, pattern: 'yyy'), '5784');
    });

    test('Hebrew default formatting preserves date and month', () {
      final formatter = HebrewDateFormatter()..hebrewFormat = true;
      final output = formatter.format(gregorian);
      expect(output, contains('סיון'));
      expect(output, contains('תש'));
    });
  });

  group('long Omer formatting', () {
    test('all 49 days have a valid and distinct index', () {
      final formatter = HebrewDateFormatter()
        ..hebrewFormat = true
        ..longOmerFormat = true;
      final calendar = JewishCalendar()
        ..setJewishDate(5784, JewishDate.NISSAN, 16);
      final outputs = <String>[];
      for (var day = 1; day <= 49; day++) {
        expect(calendar.getDayOfOmer(), day);
        final output = formatter.formatOmer(calendar);
        expect(output, isNotEmpty);
        outputs.add(output);
        calendar.forward();
      }
      expect(outputs.toSet().length, 49);
      expect(outputs.first, contains('אֶחָד'));
      expect(outputs.last, contains('שִׁבְעָה שָׁבוּעוֹת'));
      expect(formatter.formatOmer(calendar), isEmpty);
    });
  });
}
