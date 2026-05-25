import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../model/license_data.dart';

/// Personal Holetportalen access card — shows the logged-in user's license
/// status for Checklist and Forms modules only.
class LicenseStatusCard extends StatelessWidget {
  final UserLicenseStatus user;

  const LicenseStatusCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brandOrangeContainer,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(
                      PhosphorIcons.key(PhosphorIconsStyle.fill),
                      size: 18,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Holetportalen Access',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          user.name,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // User avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHover,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Checklist row ────────────────────────────────────────────────
            _ModuleRow(
              icon: PhosphorIcons.checkSquare(PhosphorIconsStyle.fill),
              label: 'Checklist',
              status: user.checklist,
              theme: theme,
            ),

            const Divider(height: 1, indent: 56),

            // ── Forms row ────────────────────────────────────────────────────
            _ModuleRow(
              icon: PhosphorIcons.filePdf(PhosphorIconsStyle.fill),
              label: 'Forms',
              status: user.forms,
              theme: theme,
            ),

            const Divider(height: 1),

            // ── Status legend ────────────────────────────────────────────────
            _StatusLegend(theme: theme),

            // ── CTA if any module is not licensed ────────────────────────────
            if (user.checklist == LicenseStatus.inactive ||
                user.forms == LicenseStatus.inactive) ...[
              const Divider(height: 1),
              _UpgradeBanner(theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Module row (one per Holetportalen module) ─────────────────────────────────
class _ModuleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final LicenseStatus status;
  final ThemeData theme;

  const _ModuleRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Module icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),

          // Module name
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Status chip
          _StatusChip(status: status),
        ],
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final LicenseStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, label, bg, fg) = switch (status) {
      LicenseStatus.active => (
          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          'Active',
          AppColors.brandOrangeContainer,
          AppColors.brandOrange,
        ),
      LicenseStatus.inactive => (
          PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
          'Not licensed',
          AppColors.surfaceHover,
          AppColors.textSecondary,
        ),
      LicenseStatus.pending => (
          PhosphorIcons.clock(PhosphorIconsStyle.fill),
          'Pending',
          const Color(0xFFFFF8E1),
          const Color(0xFFF59E0B),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status legend ─────────────────────────────────────────────────────────────
/// Always-visible key explaining the three possible license states.
class _StatusLegend extends StatelessWidget {
  final ThemeData theme;
  const _StatusLegend({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status key',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _legendItem(
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                label: 'Active — ready to use',
                fg: AppColors.brandOrange,
                bg: AppColors.brandOrangeContainer,
              ),
              _legendItem(
                icon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
                label: 'Pending — awaiting activation',
                fg: const Color(0xFFF59E0B),
                bg: const Color(0xFFFFF8E1),
              ),
              _legendItem(
                icon: PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                label: 'Not licensed — contact admin',
                fg: AppColors.textSecondary,
                bg: AppColors.surfaceHover,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.extraSmall),
          ),
          child: Icon(icon, size: 12, color: fg),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
}

// ── Upgrade banner (shown when any module is inactive) ────────────────────────
class _UpgradeBanner extends StatelessWidget {
  final ThemeData theme;
  const _UpgradeBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.info(PhosphorIconsStyle.fill),
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Contact your admin to activate missing modules.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
