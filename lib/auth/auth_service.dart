abstract class AuthService {
  Future<String?> currentToken();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Stream<bool> authChanges();
  String? get displayName;
}
