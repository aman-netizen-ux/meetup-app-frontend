import 'package:flutter_test/flutter_test.dart';
import 'package:meetup_app_frontend/features/circles/domain/polyline_decoder.dart';

void main() {
  test('decodes provider polyline coordinates at the declared precision', () {
    final points = const PolylineDecoder().decode(
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      5,
    );

    expect(points, hasLength(3));
    expect(points[0].latitude, closeTo(38.5, 0.00001));
    expect(points[0].longitude, closeTo(-120.2, 0.00001));
    expect(points[2].latitude, closeTo(43.252, 0.00001));
    expect(points[2].longitude, closeTo(-126.453, 0.00001));
  });
}
