import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token';

  /// JWT 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    print('✅ JWT 저장 완료: $token');
  }

  /// JWT 토큰 불러오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('📦 저장된 JWT 불러오기: $token');
    return token;
  }

  /// JWT 토큰 삭제
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('🗑️ JWT 삭제 완료');
  }

}
