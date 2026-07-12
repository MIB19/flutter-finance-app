import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  const AuthState._(this.status, this.error);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);
  const AuthState.authenticating() : this._(AuthStatus.authenticating, null);
  const AuthState.authenticated() : this._(AuthStatus.authenticated, null);
  const AuthState.unauthenticated([String? error]) : this._(AuthStatus.unauthenticated, error);

  @override
  List<Object?> get props => [status, error];
}
