import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keuangan_app/auth/auth_bloc.dart';
import 'package:keuangan_app/auth/auth_event.dart';
import 'package:keuangan_app/auth/auth_state.dart';
import 'package:keuangan_app/auth/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService auth;

  setUp(() {
    auth = MockAuthService();
    when(() => auth.authChanges()).thenAnswer((_) => const Stream.empty());
  });

  blocTest<AuthBloc, AuthState>(
    'emits Authenticated when a token exists on start',
    build: () {
      when(() => auth.currentToken()).thenAnswer((_) async => 'tok');
      return AuthBloc(auth);
    },
    act: (b) => b.add(AuthStarted()),
    expect: () => [const AuthState.authenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits Unauthenticated when no token on start',
    build: () {
      when(() => auth.currentToken()).thenAnswer((_) async => null);
      return AuthBloc(auth);
    },
    act: (b) => b.add(AuthStarted()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'sign-in success -> Authenticated',
    build: () {
      when(() => auth.signInWithGoogle()).thenAnswer((_) async {});
      when(() => auth.currentToken()).thenAnswer((_) async => 'tok');
      return AuthBloc(auth);
    },
    act: (b) => b.add(AuthSignInRequested()),
    expect: () => [const AuthState.authenticating(), const AuthState.authenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'sign-in failure -> error then Unauthenticated',
    build: () {
      when(() => auth.signInWithGoogle()).thenThrow(Exception('cancelled'));
      return AuthBloc(auth);
    },
    act: (b) => b.add(AuthSignInRequested()),
    expect: () => [
      const AuthState.authenticating(),
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.unauthenticated).having((s) => s.error, 'error', isNotNull),
    ],
  );
}
