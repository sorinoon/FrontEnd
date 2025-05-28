import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Pages/NOK_SettingsProvider.dart';
import '../widgets/GlobalGoBackButtonWhite.dart';

class CustomMapScreen extends StatelessWidget {
  final String userName; // 사용자 이름
  final String mapImage; // 사용자별 지도 이미지 경로
  final String nearestStation; // 사용자별 가장 가까운 역

  const CustomMapScreen({
    super.key,
    required this.userName,
    required this.mapImage,
    required this.nearestStation,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeOffset = Provider.of<NOKSettingsProvider>(context).fontSizeOffset;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 사용자별 지도 배경 이미지
          Positioned.fill(
            child: Image.asset(
              mapImage,
              fit: BoxFit.cover,
            ),
          ),

          // 마커 중앙 표시
          Center(
            child: Image.asset(
              'assets/images/marker_location.png',
              width: 50,
              height: 50,
            ),
          ),

          // 상단 제목 바
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
                    '$userName님의 현재위치',
                    style: TextStyle(
                      fontSize: 24 + fontSizeOffset,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '가장 가까운 역은 $nearestStation입니다',
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

          // 뒤로가기 버튼 (위치 고정)
          const GlobalGoBackButtonWhite(),
        ],
      ),
    );
  }
}
