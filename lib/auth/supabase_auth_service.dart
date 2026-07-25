import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Real auth: Google native sign-in -> Supabase signInWithIdToken.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _supabase;
  final GoogleSignIn _google;

  SupabaseAuthService(this._supabase, {required String webClientId})
      : _google = GoogleSignIn(serverClientId: webClientId);

  @override
  Future<String?> currentToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    if (!session.isExpired) return session.accessToken;
    // Supabase.initialize() doesn't await its internal session-recovery/refresh
    // (it's fire-and-forget), so a token that expired while the app was closed
    // can still be sitting in currentSession when this is first called. Refresh
    // explicitly rather than handing the backend a token we already know is stale.
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session?.accessToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) throw Exception('login dibatalkan');
    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('idToken kosong');
    await _supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
  }

  @override
  Future<void> signOut() async {
    await _google.signOut();
    await _supabase.auth.signOut();
  }

  @override
  Stream<bool> authChanges() =>
      _supabase.auth.onAuthStateChange.map((e) => e.session != null);

  @override
  String? get displayName => _supabase.auth.currentUser?.userMetadata?['full_name'] as String?;
}
