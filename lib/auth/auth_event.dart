import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}
class AuthSignInRequested extends AuthEvent {}
class AuthSignOutRequested extends AuthEvent {}
class AuthChanged extends AuthEvent {
  final bool signedIn;
  AuthChanged(this.signedIn);
  @override
  List<Object?> get props => [signedIn];
}
