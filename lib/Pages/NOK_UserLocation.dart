import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../widgets/GlobalGoBackButtonWhite.dart';
import 'package:latlong2/latlong.dart';

class CustomMapScreen extends StatefulWidget {
  final String userName; // 사용자 이름
  final String mapImage; // 사용자별 지도 이미지 경로
  final String nearestStation; // 사용자별 가장 가까운 역
  final LatLng location;

  const CustomMapScreen({
    required this.userName,
    required this.mapImage,
    required this.nearestStation,
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<CustomMapScreen> {
  static const MethodChannel _channel = MethodChannel('tmap_channel');

  @override
  void initState() {
    super.initState();
    _initMap();  // initState에서는 build() 밖에 있어야 함
  }

  Future<void> _initMap() async {
    try {
      // 네이티브 쪽에 마커 추가 요청
      await _channel.invokeMethod('addFixedUserMarker', {
        'latitude': widget.location.latitude,
        'longitude': widget.location.longitude,
        'id': widget.userName,
      });
    } on PlatformException catch (e) {
      print('Failed to initialize map: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<NOKSettingsProvider>(context).fontSizeOffset;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: AndroidView(
                viewType: 'TMapNativeView',
                layoutDirection: TextDirection.ltr,
                creationParams: {
                  'latitude': widget.location.latitude,
                  'longitude': widget.location.longitude,
                },
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              padding: const EdgeInsets.only(top: 10),
              color: const Color(0xff80C5A4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.userName}님의 현재위치',
                    style: TextStyle(
                      fontSize: 24 + fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '가장 가까운 역은 ${widget.nearestStation}입니다',
                    style: TextStyle(
                      fontSize: 18 + fontSizeOffset,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const GlobalGoBackButtonWhite(),
        ],
      ),
    );
  }
}
