import '../Pages/Page_NOKList.dart';
import '../Pages/Page_NOKRegistration.dart';
import 'package:flutter/material.dart';
import '../widgets/GlobalMicButton.dart';
import '../Pages/Page_NOKList.dart';
import '../Pages/Page_NOKRegistration.dart';

class PageSetting extends StatelessWidget {
  const PageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 상단 바 (뒤로가기 + 가운데 설정 텍스트)
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          '설정',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28),
                          onPressed: () {
                            Navigator.pop(context); // 이전 화면으로 돌아가기
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text("카카오계정", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("hansungKim123@naver.com", style: TextStyle(color: Colors.grey)),
                  const Divider(height: 32),

                  _buildSwitchTile('저전력 모드', '네비게이션 사용 시 자동으로 저전력 모드로 전환합니다.', true),
                  _buildSwitchTile('진동 모드', '어플리케이션 알림을 진동으로 전환합니다.', false),
                  _buildSwitchTile('글자 크기 키우기', '저시력 사용자를 위해 글자 크기를 최대로 키웁니다.', false),

                  const Divider(height: 32),

                  const Text("보호자 관리", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  _buildArrowTile(
                    '보호자 등록하기',
                    subtitle: '보호자를 추가로 등록합니다.\n고유 번호 혹은 QR 코드를 이용할 수 있습니다.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PageNokregistration()),
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildArrowTile(
                    '보호자 목록',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PageNOKList()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          GlobalMicButton(
            onPressed: () {
              // 마이크 버튼 눌렀을 때 동작 정의
              print('마이크 버튼 클릭');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Switch(
              value: initialValue,
              activeColor: Colors.yellow,
              onChanged: (val) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildArrowTile(String title, {String? subtitle, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
