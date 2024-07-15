import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'config.dart';

class SubwayApiService {
  Future<Map<String, List<Map<String, String>>>> getSubwayInfo(String stationName) async {
    final apiKey = Config.apiKey;
    final encodedStationName = Uri.encodeComponent(stationName);
    final url = '${Config.apiBaseUrl}/$apiKey/xml/realtimeStationArrival/0/10/$encodedStationName';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final document = XmlDocument.parse(decodedBody);
      final rows = document.findAllElements('row');

      List<Map<String, String>> trainInfoUp = [];
      List<Map<String, String>> trainInfoDown = [];

      for (var row in rows) {
        final trainData = {
          'subwayId': row.findElements('subwayId').single.text,
          'updnLine': row.findElements('updnLine').single.text,
          'trainLineNm': row.findElements('trainLineNm').single.text,
          'statnNm': row.findElements('statnNm').single.text,
          'btrainSttus': row.findElements('btrainSttus').single.text,
          'arvlMsg2': row.findElements('arvlMsg2').single.text,
          'arvlMsg3': row.findElements('arvlMsg3').single.text,
        };

        if (trainData['updnLine'] == '상행') {
          trainInfoUp.add(trainData);
        } else if (trainData['updnLine'] == '하행') {
          trainInfoDown.add(trainData);
        }
      }

      return {'up': trainInfoUp, 'down': trainInfoDown};
    } else {
      throw Exception('Failed to load subway info');
    }
  }

  Color getSubwayColor(String subwayId) {
    switch (subwayId) {
      case '1001':
        return Colors.blue;
      case '1002':
        return Colors.green;
      case '1003':
        return Colors.orange;
      case '1004':
        return Colors.blue[300]!;
      case '1005':
        return Colors.purple;
      case '1006':
        return Colors.brown;
      case '1007':
        return Colors.lightGreen;
      case '1008':
        return Colors.pink;
      case '1009':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  String getSubwayName(String subwayId) {
    switch (subwayId) {
      case '1001':
        return '1호선';
      case '1002':
        return '2호선';
      case '1003':
        return '3호선';
      case '1004':
        return '4호선';
      case '1005':
        return '5호선';
      case '1006':
        return '6호선';
      case '1007':
        return '7호선';
      case '1008':
        return '8호선';
      case '1009':
        return '9호선';
      default:
        return subwayId;
    }
  }
}
