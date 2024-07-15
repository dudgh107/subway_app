import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class NearestStationFinder {
  Future<String> findNearestStation() async {
    try {
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
      print('위치정보 $lat  $lon');
      String nearestStation = "못찾았습니다.";

      String jsonString = await rootBundle.loadString('assets/station_coordinate.json');
      final List<dynamic> stations = json.decode(jsonString);

      double minDistance = double.infinity;
      for (var row in stations) {
        if (row.containsKey('lat') && row.containsKey('lng')) {
          double stationLat = row['lat'];
          double stationLon = row['lng'];
          double distance = _calculateDistance(lat, lon, stationLat, stationLon);

          if (distance < minDistance) {
            minDistance = distance;
            nearestStation = row['name'];
          }
        }
      }
      return nearestStation;
    } catch (e) {
      print('Error in findNearestStation: $e');
      return "위치를 찾는 중 오류가 발생했습니다: $e";
    }
  }

  Future<Position> _determinePosition() async {
    print('Checking location service...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    print('Checking location permission...');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Location permission denied, requesting permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied after request');
        throw Exception('위치 권한이 거부되었습니다');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      throw Exception('위치 권한이 영구적으로 거부되었습니다, 앱 설정에서 변경해주세요.');
    }

    print('Getting current position...');
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting current position: $e');
      throw Exception('현재 위치를 가져오는 데 실패했습니다: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double c = cos((lat2 - lat1) * p);
    final double a = 0.5 - c / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}