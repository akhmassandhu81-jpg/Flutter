/// Legacy shim — all real operations now live in UserRepository.
/// Kept so that any residual imports don't break compilation.
/// Do not add new logic here.
class UserService {
  UserService._();
  static final UserService instance = UserService._();
}
