import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with TickerProviderStateMixin {
  String _pin = '';
  static const int _pinLength = 4;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _successScale = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    if (_pin.length >= _pinLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += key);
    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 100), () {
        context.read<AuthCubit>().authenticateWithPin(_pin);
      });
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onError() {
    HapticFeedback.heavyImpact();
    setState(() => _pin = '');
    _shakeCtrl.forward().then((_) => _shakeCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _successCtrl.forward().then((_) => context.go('/home'));
        } else if (state is AuthPinError) {
          _onError();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.message} (${state.attemptsLeft} attempts left)'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AuthError) {
          _onError();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
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
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 32),
                  const Text('Enter Your PIN',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Use your 4-digit PIN to access your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 48),
                  // PIN dots
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value * ((_shakeCtrl.value * 20).round().isEven ? 1 : -1), 0),
                      child: child,
                    ),
                    child: AnimatedBuilder(
                      animation: _successScale,
                      builder: (_, child) => Transform.scale(scale: _successScale.value, child: child),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pinLength, (i) => _PinDot(filled: i < _pin.length)),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Numpad
                  _buildNumpad(),
                  const SizedBox(height: 24),
                  // Use biometric
                  GestureDetector(
                    onTap: () => context.read<AuthCubit>().authenticateWithBiometric(),
                    child: const Text('Use Biometric',
                        style: TextStyle(color: AppColors.primary, fontSize: 14,
                            fontWeight: FontWeight.w600)),
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

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        if (key.isEmpty) return const SizedBox();
        return _NumpadKey(
          label: key,
          onTap: () => key == '⌫' ? _onDelete() : _onKey(key),
          isDelete: key == '⌫',
        );
      },
    );
  }
}

class _PinDot extends StatelessWidget {
  final bool filled;
  const _PinDot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 16, height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        boxShadow: filled
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

class _NumpadKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  const _NumpadKey({required this.label, required this.onTap, this.isDelete = false});

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1, end: 0.9).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDelete ? Colors.transparent : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: widget.isDelete ? null : Border.all(color: AppColors.border),
          ),
          child: Center(
            child: widget.isDelete
                ? const Icon(Icons.backspace_outlined, color: AppColors.textSecondary, size: 22)
                : Text(widget.label,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}
