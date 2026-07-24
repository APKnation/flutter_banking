import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkBiometrics();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go('/home');
        if (state is AuthPinRequired) context.go('/auth/pin');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Text('NeoBank',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary, letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  // Biometric Icon with pulse
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          ScaleTransition(
                            scale: _pulse,
                            child: GestureDetector(
                              onTap: () => context.read<AuthCubit>().authenticateWithBiometric(),
                              child: Container(
                                width: 130, height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: state is AuthLoading
                                      ? AppColors.darkGradient
                                      : AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: state is AuthLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary, strokeWidth: 3))
                                    : const Icon(Icons.fingerprint_rounded,
                                        color: Colors.white, size: 68),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Touch to Unlock',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          const Text('Place your finger on the sensor\nto access your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                                  height: 1.5)),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Use PIN Instead',
                    style: AppButtonStyle.secondary,
                    icon: Icons.dialpad_rounded,
                    onPressed: () => context.go('/auth/pin'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
