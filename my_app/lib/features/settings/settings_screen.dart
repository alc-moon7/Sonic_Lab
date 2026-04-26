import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/audio_session_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/sonic_lab_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/sonic_logo.dart';
import 'widgets/settings_group.dart';
import 'widgets/settings_section_label.dart';
import 'widgets/settings_tile.dart';
import 'widgets/terminate_session_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppConstants.navHeight + 34),
          child: Column(
            children: [
              AppTopBar(
                actions: [
                  PopupMenuButton<String>(
                    color: AppColors.surface,
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textSecondary),
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(value)),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: 'About SONIC_LAB', child: Text('About')),
                      PopupMenuItem(
                          value: 'Changelog v2.4.1-STABLE',
                          child: Text('Changelog')),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  52,
                  AppConstants.horizontalPadding,
                  0,
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Settings', style: AppTextStyles.title),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Configure your audio laboratory environment',
                        style: AppTextStyles.subtitle,
                      ),
                    ),
                    const SizedBox(height: 38),
                    const SettingsSectionLabel(text: 'SYSTEM CONTROL'),
                    const SizedBox(height: 18),
                    SettingsGroup(
                      children: [
                        const SettingsTile(
                          icon: Icons.person_outline,
                          iconColor: AppColors.water,
                          iconBackground: Color(0xFF1E3A5F),
                          title: 'User Profile',
                          subtitle: 'Manage your preferences',
                          trailing: Icon(Icons.chevron_right),
                        ),
                        SettingsTile(
                          icon: Icons.notifications_active,
                          iconColor: AppColors.lime,
                          iconBackground: const Color(0xFF303A12),
                          title: 'Alert Notifications',
                          subtitle: 'Sound & vibration triggers',
                          trailing: Switch(
                            value: settings.notificationsEnabled,
                            onChanged: (value) => unawaited(
                              ref
                                  .read(settingsProvider.notifier)
                                  .setNotificationsEnabled(value),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const SettingsSectionLabel(
                      text: 'ASSISTANCE',
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 18),
                    const SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.help,
                          iconColor: AppColors.textSecondary,
                          iconBackground: AppColors.transparent,
                          title: 'Help & Support',
                          trailing: Icon(Icons.open_in_new),
                        ),
                        SettingsTile(
                          icon: Icons.star,
                          iconColor: AppColors.textSecondary,
                          iconBackground: AppColors.transparent,
                          title: 'Rate Us',
                          trailing: _RatingBadge(),
                        ),
                        SettingsTile(
                          icon: Icons.share,
                          iconColor: AppColors.textSecondary,
                          iconBackground: AppColors.transparent,
                          title: 'Refer a Labmate',
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const SettingsSectionLabel(
                      text: 'LEGAL & INFO',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 18),
                    const SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.verified_user,
                          iconColor: AppColors.textSecondary,
                          iconBackground: AppColors.transparent,
                          title: 'Privacy Policy',
                          trailing: Icon(Icons.chevron_right),
                        ),
                        SettingsTile(
                          icon: Icons.info,
                          iconColor: AppColors.textSecondary,
                          iconBackground: AppColors.transparent,
                          title: 'About',
                          trailing: _VersionBadge(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    TerminateSessionButton(
                      onPressed: () => _confirmTerminate(context, ref),
                    ),
                    const SizedBox(height: 64),
                    const Column(
                      children: [
                        SonicLogo(
                            dimmed: true, centered: true, showWordmark: false),
                        SizedBox(height: 12),
                        Text(
                          'SONIC_LAB',
                          style: TextStyle(
                            color: AppColors.controlSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

  Future<void> _confirmTerminate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Session?'),
        content: const Text(
          'This stops all active tones and clears the current session state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(audioSessionProvider.notifier).terminateSession();
    await ref.read(sonicLabProvider.notifier).stop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All audio sessions terminated')),
      );
    }
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '5.0',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.star, color: AppColors.warning, size: 14),
      ],
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'v2.4.1-STABLE',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
