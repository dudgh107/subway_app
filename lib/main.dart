import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'subway_info_page.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '서울 지하철 실시간 정보',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SubwayInfoPage(),
    );
  }
}
