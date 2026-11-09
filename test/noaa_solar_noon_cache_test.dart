import 'package:kosher_dart/kosher_dart.dart';
import 'package:kosher_dart/src/astronomical_calendar.dart';
import 'package:kosher_dart/src/util/noaa_calculator.dart';
import 'package:test/test.dart';

void main() {
  GeoLocation geo(double lat, double lon, DateTime date) =>
      GeoLocation.setLocation('test', lat, lon, date);

  group('NOAA one-entry solar-noon cache', () {
    test('matches an independent fresh calculator over changing inputs', () {
      final reused = NOAACalculator();
      for (final date in [
        DateTime.utc(2024, 6, 21), DateTime.utc(2024, 12, 21),
        DateTime.utc(2025, 3, 20),
      ]) {
        for (final loc in [
          geo(31.7964, 35.2454, date),
          geo(40.095, -74.222, date),
          geo(-33.925, 18.4241, date),
        ]) {
          for (final zenith in [90.0, 96.0, 102.0, 108.0]) {
            final fresh = NOAACalculator();
            expect(reused.getUTCSunrise(date, loc, zenith, false),
                closeTo(fresh.getUTCSunrise(date, loc, zenith, false), 1e-9));
            expect(reused.getUTCSunset(date, loc, zenith, false),
                closeTo(fresh.getUTCSunset(date, loc, zenith, false), 1e-9));
          }
        }
      }
    });

    test('longitude, elevation and day changes invalidate relevant calculations', () {
      final reused = NOAACalculator();
      final june = DateTime.utc(2024, 6, 21);
      final december = DateTime.utc(2024, 12, 21);
      final loc = geo(31.7964, 35.2454, june);
      reused.getUTCSunrise(june, loc, 90.0, true);
      loc.setLongitude(longitude: -74.222);
      expect(reused.getUTCSunrise(june, loc, 96.0, true),
          closeTo(NOAACalculator().getUTCSunrise(june, loc, 96.0, true), 1e-9));
      loc.setElevation(850);
      expect(reused.getUTCSunset(june, loc, 90.0, true),
          closeTo(NOAACalculator().getUTCSunset(june, loc, 90.0, true), 1e-9));
      expect(reused.getUTCSunset(december, loc, 102.0, false),
          closeTo(NOAACalculator().getUTCSunset(december, loc, 102.0, false), 1e-9));
    });
  });

  group('polar day and night', () {
    test('NOAA does not fabricate a sunrise where no sunrise occurs', () {
      for (final date in [
        DateTime.utc(2024, 6, 21), DateTime.utc(2024, 12, 21),
      ]) {
        final loc = geo(85.0, 0.0, date);
        final calc = NOAACalculator();
        expect(calc.getUTCSunrise(date, loc, 90.0, false).isNaN, isTrue);
        expect(calc.getUTCSunset(date, loc, 90.0, false).isNaN, isTrue);
      }
    });

    test('the astronomical API propagates polar no-rise as null', () {
      for (final date in [
        DateTime.utc(2024, 6, 21), DateTime.utc(2024, 12, 21),
      ]) {
        final cal = AstronomicalCalendar(geoLocation: geo(85.0, 0.0, date));
        expect(cal.getSeaLevelSunrise(), isNull);
        expect(cal.getSeaLevelSunset(), isNull);
      }
    });
  });
}
