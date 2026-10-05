import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';
import '../models/user_session_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userSessionProvider = StateNotifierProvider<UserSessionNotifier, UserSession>((ref) {
  final authService = ref.watch(authServiceProvider);
  return UserSessionNotifier(authService);
});

class UserSessionNotifier extends StateNotifier<UserSession> {
  final AuthService _authService;

  UserSessionNotifier(this._authService) : super(UserSession.guest()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _authService.getCurrentSession();
    state = session;
  }

  Future<void> updateSession(UserSession newSession) async {
    await _authService.saveSession(newSession);
    state = newSession;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = UserSession.guest();
  }
}
