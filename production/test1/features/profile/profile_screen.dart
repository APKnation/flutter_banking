import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/banking_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = BankingRepository();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await _repo.getUser();
      setState(() { _user = user; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _user == null
              ? const Center(
                  child: Text('Profile not found in Firebase.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : _buildContent(context, _user!),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Center(
                    child: Text(user.initials,
                        style: const TextStyle(color: Colors.white, fontSize: 36,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceElevated, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22,
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('${(user.membershipTier ?? 'standard').toUpperCase()} MEMBER',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                        fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SettingsSection(
            title: 'Account',
            items: [
              _SettingsItem(icon: Icons.person_outline_rounded, title: 'Personal Information'),
              _SettingsItem(icon: Icons.security_rounded, title: 'Security & PIN'),
              _SettingsItem(icon: Icons.notifications_none_rounded, title: 'Notifications'),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Preferences',
            items: [
              _SettingsItem(icon: Icons.language_rounded, title: 'Language', trailing: 'Swahili'),
              _SettingsItem(icon: Icons.dark_mode_outlined, title: 'Appearance', trailing: 'Dark'),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/auth/pin'),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(title, style: const TextStyle(color: AppColors.textSecondary,
              fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: AppColors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              side: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(e.value.icon, color: AppColors.primary, size: 22),
                      title: Text(e.value.title,
                          style: const TextStyle(color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500, fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.value.trailing != null) ...[
                            Text(e.value.trailing!,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ),
                      onTap: () {},
                    ),
                    if (e.key < items.length - 1)
                      const Divider(color: AppColors.border, height: 1, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? trailing;
  _SettingsItem({required this.icon, required this.title, this.trailing});
}
