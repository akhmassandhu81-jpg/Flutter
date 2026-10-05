import '../../models/user_session_model.dart';

class AuthService {
  UserSession _cachedSession = UserSession.guest();

  Future<UserSession> getCurrentSession() async {
    return _cachedSession;
  }

  Future<void> saveSession(UserSession session) async {
    _cachedSession = session;
  }

  Future<void> logout() async {
    _cachedSession = UserSession.guest();
  }
}
