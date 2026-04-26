import 'package:flutter/material.dart';

import '../../models/session_result.dart';
import '../theme/app_colors.dart';

class SessionStatusCard extends StatelessWidget {
  const SessionStatusCard({
    super.key,
    required this.session,
    required this.activeColor,
  });

  final SessionState session;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    if (session.status == SessionStatus.idle) {
      return const SizedBox.shrink();
    }
    final isPlaying = session.status == SessionStatus.playing;
    final icon = isPlaying ? Icons.graphic_eq : Icons.check_circle;
    final title = session.message ??
        (isPlaying ? 'Cleaning session running' : 'Session complete');
    final subtitle = isPlaying
        ? '${session.remainingSeconds}s remaining • ${session.currentFrequency.round()} Hz'
        : 'You can repeat the cycle if the speaker still sounds muffled.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: activeColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
