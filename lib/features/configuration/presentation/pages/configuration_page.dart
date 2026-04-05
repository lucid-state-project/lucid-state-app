import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/cards/app_card.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _quietHours = true;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.analytics);
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label - Coming soon')),
    );
  }

  void _handleSignOut() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryLight.withOpacity(0.28),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 56,
                                  backgroundImage: AssetImage('assets/images/Alex Rivers_PP.png'),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: 6,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Alex Rivers',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'MASTER OF FLOW',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryLight,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    _sectionLabel('ACCOUNT SETTINGS'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      borderRadius: 28,
                      elevation: 1,
                      child: Column(
                        children: [
                          _SettingsNavRow(
                            iconAsset: 'assets/icons/configuration/Personal Information.png',
                            title: 'Personal Information',
                            onTap: () => _showComingSoon('Personal Information'),
                          ),
                          _SettingsNavRow(
                            iconAsset: 'assets/icons/configuration/Security.png',
                            title: 'Security',
                            onTap: () => _showComingSoon('Security'),
                          ),
                          _SettingsNavRow(
                            iconAsset: 'assets/icons/configuration/Linked Account.png',
                            title: 'Linked Accounts',
                            onTap: () => _showComingSoon('Linked Accounts'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('APP PREFERENCES'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      borderRadius: 28,
                      elevation: 1,
                      child: Column(
                        children: [
                          _SettingsToggleRow(
                            iconAsset: 'assets/icons/configuration/Notification.png',
                            title: 'Notifications',
                            value: _notifications,
                            onChanged: (v) => setState(() => _notifications = v),
                          ),
                          _SettingsToggleRow(
                            iconAsset: 'assets/icons/configuration/Dark Mode.png',
                            title: 'Dark Mode',
                            value: _darkMode,
                            onChanged: (v) => setState(() => _darkMode = v),
                          ),
                          _SettingsToggleRow(
                            iconAsset: 'assets/icons/configuration/Quite Hours.png',
                            title: 'Quiet Hours',
                            value: _quietHours,
                            onChanged: (v) => setState(() => _quietHours = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('DATA & PRIVACY'),
                    const SizedBox(height: 12),
                    _PrivacyCard(
                      iconAsset: 'assets/icons/configuration/Icon.png',
                      title: 'Export Data',
                      subtitle: 'Download your mindfulness history',
                      onTap: () => _showComingSoon('Export Data'),
                    ),
                    const SizedBox(height: 12),
                    _PrivacyCard(
                      iconAsset: 'assets/icons/configuration/Icon-1.png',
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your mental data',
                      onTap: () => _showComingSoon('Privacy Policy'),
                    ),
                    const SizedBox(height: 26),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: _handleSignOut,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryDark, AppColors.primaryLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withOpacity(0.42),
                                blurRadius: 20,
                                spreadRadius: 1.5,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppColors.primaryDark.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Sign Out',
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text(
                        'App Version 2.4.1 (Lucid Build)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.iconAsset,
    required this.title,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            _CircleIcon(iconAsset: iconAsset),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String iconAsset;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          _CircleIcon(iconAsset: iconAsset),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.95,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryLight,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD7DBE0),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AppCard(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          borderRadius: 24,
          elevation: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(iconAsset),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.iconAsset});

  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Image.asset(iconAsset, fit: BoxFit.contain),
      ),
    );
  }
}
