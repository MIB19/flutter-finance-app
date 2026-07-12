import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _auth;
  StreamSubscription<bool>? _sub;

  AuthBloc(this._auth) : super(const AuthState.unknown()) {
    on<AuthStarted>((_, emit) async {
      final token = await _auth.currentToken();
      emit(token != null ? const AuthState.authenticated() : const AuthState.unauthenticated());
      _sub ??= _auth.authChanges().listen((signedIn) => add(AuthChanged(signedIn)));
    });

    on<AuthSignInRequested>((_, emit) async {
      emit(const AuthState.authenticating());
      try {
        await _auth.signInWithGoogle();
        final token = await _auth.currentToken();
        emit(token != null ? const AuthState.authenticated() : const AuthState.unauthenticated('login gagal'));
      } catch (e) {
        emit(AuthState.unauthenticated(e.toString()));
      }
    });

    on<AuthSignOutRequested>((_, emit) async {
      await _auth.signOut();
      emit(const AuthState.unauthenticated());
    });

    on<AuthChanged>((e, emit) {
      emit(e.signedIn ? const AuthState.authenticated() : const AuthState.unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
