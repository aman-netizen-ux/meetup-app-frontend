import 'entities/geo_point.dart';

class PolylineDecoder {
  const PolylineDecoder();

  List<GeoPoint> decode(String? encoded, int? precision) {
    if (encoded == null || encoded.isEmpty || precision == null) return const [];
    final factor = _powerOfTen(precision);
    final points = <GeoPoint>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;
    while (index < encoded.length) {
      final lat = _decodeValue(encoded, index);
      index = lat.$2;
      if (index > encoded.length) break;
      final lon = _decodeValue(encoded, index);
      index = lon.$2;
      latitude += lat.$1;
      longitude += lon.$1;
      points.add(GeoPoint(
        latitude: latitude / factor,
        longitude: longitude / factor,
      ));
    }
    return points;
  }

  (int, int) _decodeValue(String value, int start) {
    var result = 0;
    var shift = 0;
    var index = start;
    var byte = 0;
    do {
      if (index >= value.length) return (0, value.length + 1);
      byte = value.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    return ((result & 1) != 0 ? ~(result >> 1) : result >> 1, index);
  }

  double _powerOfTen(int precision) {
    var result = 1.0;
    for (var i = 0; i < precision; i++) {
      result *= 10;
    }
    return result;
  }
}
