// Run: dart run benchmark/noaa_daily_zmanim_benchmark.dart
// Compare branches using the same SDK and machine; no speed claim is assumed.
import 'package:kosher_dart/kosher_dart.dart';

void main() {
  final day = DateTime.utc(2024, 6, 21);
  final loc = GeoLocation.setLocation('Jerusalem', 31.7964, 35.2454, day);
  final cal = ComplexZmanimCalendar.intGeoLocation(loc);
  const iterations = 100;
  final sw = Stopwatch()..start();
  var total = 0;
  for (var i = 0; i < iterations; i++) {
    for (final zenith in [90.0, 96.0, 102.0, 106.1, 108.0, 112.0]) {
      if (cal.getSunriseOffsetByDegrees(zenith) != null) total++;
      if (cal.getSunsetOffsetByDegrees(zenith) != null) total++;
    }
  }
  sw.stop();
  print('NOAA zmanim: ' + total.toString() + ' times in ' +
      sw.elapsedMicroseconds.toString() + ' microseconds (100 iterations)');
}
