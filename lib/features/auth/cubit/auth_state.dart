import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }

class AuthLoading extends AuthState { const AuthLoading(); }

class AuthPinRequired extends AuthState { const AuthPinRequired(); }

class AuthBiometricAvailable extends AuthState {
  final bool isFaceId;
  const AuthBiometricAvailable({this.isFaceId = false});
  @override List<Object?> get props => [isFaceId];
}

class AuthAuthenticated extends AuthState { const AuthAuthenticated(); }

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}

class AuthPinError extends AuthState {
  final String message;
  final int attemptsLeft;
  const AuthPinError(this.message, this.attemptsLeft);
  @override List<Object?> get props => [message, attemptsLeft];
}
