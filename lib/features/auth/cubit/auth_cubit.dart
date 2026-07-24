import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _correctPin = '1234'; // Demo PIN
  int _attempts = 3;

  AuthCubit() : super(const AuthInitial());

  Future<void> checkBiometrics() async {
    emit(const AuthLoading());
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = await _localAuth.isDeviceSupported();
      if (canCheck && isAvailable) {
        final biometrics = await _localAuth.getAvailableBiometrics();
        final isFace = biometrics.contains(BiometricType.face);
        emit(AuthBiometricAvailable(isFaceId: isFace));
      } else {
        emit(const AuthPinRequired());
      }
    } catch (_) {
      emit(const AuthPinRequired());
    }
  }

  Future<void> authenticateWithBiometric() async {
    emit(const AuthLoading());
    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access NeoBank',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (success) {
        emit(const AuthAuthenticated());
      } else {
        emit(const AuthPinRequired());
      }
    } catch (_) {
      emit(const AuthPinRequired());
    }
  }

  Future<void> authenticateWithPin(String pin) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    if (pin == _correctPin) {
      _attempts = 3;
      emit(const AuthAuthenticated());
    } else {
      _attempts--;
      if (_attempts <= 0) {
        _attempts = 3;
        emit(const AuthError('Too many failed attempts. Please try again later.'));
      } else {
        emit(AuthPinError('Incorrect PIN', _attempts));
      }
    }
  }

  void goToPin() => emit(const AuthPinRequired());

  void reset() {
    _attempts = 3;
    emit(const AuthInitial());
  }
}
