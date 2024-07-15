import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'subway_api_service.dart';
import 'nearest_station_finder.dart';

class SubwayInfoPage extends StatefulWidget {
  @override
  _SubwayInfoPageState createState() => _SubwayInfoPageState();
}

class _SubwayInfoPageState extends State<SubwayInfoPage> {
  final _logger = Logger('SubwayInfoPage');
  String _stationName = '';
  List<Map<String, String>> _trainInfoUp = [];
  List<Map<String, String>> _trainInfoDown = [];
  String _nearestStation = '';
  final SubwayApiService _subwayApiService = SubwayApiService();
  final NearestStationFinder _nearestStationFinder = NearestStationFinder();
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getNearestStation();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getNearestStation() async {
    try {
      String nearestStation = await _nearestStationFinder.findNearestStation();
      print('nearestStation : $nearestStation');
      setState(() {
        _nearestStation = nearestStation;
        _stationName = nearestStation;
        _textEditingController.text = nearestStation;
        _focusNode.requestFocus();
      });
      _getSubwayInfo();
    } catch (e, stackTrace) {
      _logger.severe('위치를 가져오는 중 에러 발생', e, stackTrace);
      _logger.severe('현재 위치를 가져오는 데 실패했습니다', e);
      print('스택 트레이스:\n$stackTrace');
    }
  }

  Future<void> _getSubwayInfo() async {
    if (_stationName.isEmpty) return;

    try {
      var trainInfo = await _subwayApiService.getSubwayInfo(_stationName);
      setState(() {
        _trainInfoUp = trainInfo['up'] ?? [];
        _trainInfoDown = trainInfo['down'] ?? [];
      });

      _logger.info('Parsed train info: $_trainInfoUp, $_trainInfoDown');
    } catch (e, stackTrace) {
      _logger.severe('지하철 정보를 가져오는 데 실패했습니다', e);
      print(stackTrace);
      setState(() {
        _trainInfoUp = [];
        _trainInfoDown = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('서울 지하철 실시간 정보'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              onChanged: (value) {
                setState(() {
                  _stationName = value;
                });
              },
              decoration: InputDecoration(
                labelText: '역 이름',
                hintText: '역 이름을 입력하세요',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _getSubwayInfo,
                ),
              ),
            ),
          ),
          ElevatedButton(
            child: Text('가장 가까운 역 찾기'),
            onPressed: _getNearestStation,
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      Text('상행'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _trainInfoUp.length,
                          itemBuilder: (context, index) {
                            final train = _trainInfoUp[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _subwayApiService.getSubwayColor(train['subwayId']!),
                                  child: Text(_subwayApiService.getSubwayName(train['subwayId']!)),
                                ),
                                title: Text('${train['trainLineNm']} (${train['updnLine']})'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${train['btrainSttus']} - ${train['arvlMsg2']}'),
                                    Text(train['arvlMsg3']!),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('하행'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _trainInfoDown.length,
                          itemBuilder: (context, index) {
                            final train = _trainInfoDown[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _subwayApiService.getSubwayColor(train['subwayId']!),
                                  child: Text(_subwayApiService.getSubwayName(train['subwayId']!)),
                                ),
                                title: Text('${train['trainLineNm']} (${train['updnLine']})'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${train['btrainSttus']} - ${train['arvlMsg2']}'),
                                    Text(train['arvlMsg3']!),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
