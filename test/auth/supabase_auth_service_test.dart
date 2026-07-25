import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keuangan_app/auth/supabase_auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
  });

  group('currentToken', () {
    test('returns the access token directly when the session is not expired', () async {
      final session = MockSession();
      when(() => session.isExpired).thenReturn(false);
      when(() => session.accessToken).thenReturn('valid-token');
      when(() => auth.currentSession).thenReturn(session);

      final service = SupabaseAuthService(client, webClientId: 'x');

      expect(await service.currentToken(), 'valid-token');
      verifyNever(() => auth.refreshSession());
    });

    test('refreshes and returns the new token when the session is expired', () async {
      final expiredSession = MockSession();
      when(() => expiredSession.isExpired).thenReturn(true);
      when(() => auth.currentSession).thenReturn(expiredSession);

      final refreshedSession = MockSession();
      when(() => refreshedSession.accessToken).thenReturn('refreshed-token');
      final response = MockAuthResponse();
      when(() => response.session).thenReturn(refreshedSession);
      when(() => auth.refreshSession()).thenAnswer((_) async => response);

      final service = SupabaseAuthService(client, webClientId: 'x');

      expect(await service.currentToken(), 'refreshed-token');
    });

    test('returns null when the session is expired and refresh fails', () async {
      final expiredSession = MockSession();
      when(() => expiredSession.isExpired).thenReturn(true);
      when(() => auth.currentSession).thenReturn(expiredSession);
      when(() => auth.refreshSession()).thenThrow(Exception('network error'));

      final service = SupabaseAuthService(client, webClientId: 'x');

      expect(await service.currentToken(), isNull);
    });

    test('returns null when there is no current session', () async {
      when(() => auth.currentSession).thenReturn(null);

      final service = SupabaseAuthService(client, webClientId: 'x');

      expect(await service.currentToken(), isNull);
    });
  });
}
