import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../model/license_data.dart';
import '../../model/user_preferences.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../widgets/dashboard/license_status_card.dart';
import '../widgets/settings/empty_defaults_card.dart';
import '../widgets/settings/manual_defaults_sheet.dart';
import '../widgets/settings/settings_card.dart';
import '../widgets/settings/smart_defaults_section.dart';
import '../widgets/settings/toggle_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        // Show snack after save/clear
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final msg = vm.snackMessage;
          if (msg != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: AppColors.surfaceContainer,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainer,
            title: const Text('Settings'),
            actions: [
              // DEV helper: simulate adding a work report
              IconButton(
                tooltip: 'Simulate work report (dev)',
                icon: Icon(
                  PhosphorIcons.plusCircle(PhosphorIconsStyle.regular),
                  size: 22,
                ),
                onPressed: vm.simulateWorkReportAdded,
              ),
            ],
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _SettingsBody(prefs: vm.prefs),
        );
      },
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────

class _SettingsBody extends StatelessWidget {
  final UserPreferences prefs;
  const _SettingsBody({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SettingsViewModel>();
    // Current user's license — in production this comes from the auth/license VM.
    final myLicense = HoletportalenLicenseData.mockCurrentUser();

    return ListView(
      // bottom: 80 NavigationBar + 24 breathing room
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: [
        // ── Smart Defaults ──────────────────────────────────────────
        const SectionLabel('Smart Defaults'),
        _buildSmartDefaults(context, vm),
        const SizedBox(height: 24),

        // ── Holetportalen Access ────────────────────────────────────
        const SectionLabel('Holetportalen Access'),
        LicenseStatusCard(user: myLicense),
        const SizedBox(height: 24),

        // ── Notifications ───────────────────────────────────────────
        const SectionLabel('Notifications'),
        _buildNotifications(context, vm),
        const SizedBox(height: 24),

        // ── AI Assistant ────────────────────────────────────────────
        const SectionLabel('AI Assistant'),
        _buildAiAssistant(context, vm),
        const SizedBox(height: 32),

        // ── Dev hint ────────────────────────────────────────────────
        Center(
          child: Text(
            'Tap  +  in the top bar to simulate a work report\n'
            'and watch the learning progress animate.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black26,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartDefaults(BuildContext context, SettingsViewModel vm) {
    // Show empty/learning card until we have enough data AND a default
    if (!prefs.hasAnyDefault) {
      return EmptyDefaultsCard(
        completedCount: prefs.usageEventCount,
        totalRequired: UserPreferences.requiredEvents,
        progress: prefs.learningProgress,
        onSetManually: () => ManualDefaultsSheet.show(context),
      );
    }
    return SmartDefaultsSection(
      prefs: prefs,
      onEdit: () => ManualDefaultsSheet.show(context),
      onClear: vm.clearManualDefaults,
    );
  }

  Widget _buildNotifications(BuildContext context, SettingsViewModel vm) {
    return SettingsCard(
      children: [
        ToggleRow(
          icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
          label: 'Daily reminder to log hours',
          subtitle: 'Reminds you at 15:30 if no hours are logged',
          value: prefs.notifyDailyHours,
          onChanged: vm.toggleNotifyDailyHours,
        ),
        const Divider(indent: 56),
        ToggleRow(
          icon: PhosphorIcons.warning(PhosphorIconsStyle.regular),
          label: 'Project deadline alerts',
          subtitle: 'Alert 3 days before a project deadline',
          value: prefs.notifyDeadlines,
          onChanged: vm.toggleNotifyDeadlines,
        ),
      ],
    );
  }

  Widget _buildAiAssistant(BuildContext context, SettingsViewModel vm) {
    return SettingsCard(
      children: [
        ToggleRow(
          icon: PhosphorIcons.sparkle(PhosphorIconsStyle.regular),
          label: 'Alpha Support',
          subtitle: 'Helps in Onboarding',
          value: prefs.aiAutoFill,
          onChanged: vm.toggleAiAutoFill,
        ),
        const Divider(indent: 56),
        ToggleRow(
          icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
          label: 'Time List — Intelligent Timesheet',
          subtitle: 'AI-powered timesheet that detects and fills gaps',
          value: prefs.aiPhotoAnalysis,
          onChanged: vm.toggleAiPhotoAnalysis,
        ),
        const Divider(indent: 56),
        // Language picker row
        ListTile(
          leading: Icon(
            PhosphorIcons.globe(PhosphorIconsStyle.regular),
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            'Language',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: DropdownButton<String>(
            value: prefs.language,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(
                value: 'nb',
                child: Text('Norwegian Bokmål'),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
            onChanged: (lang) {
              if (lang != null) vm.changeLanguage(lang);
            },
          ),
        ),
      ],
    );
  }
}
