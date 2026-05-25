import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodel/manual_defaults_viewmodel.dart';
import '../../../viewmodel/settings_viewmodel.dart';

/// Modal bottom sheet for manually setting Smart Defaults.
/// Has its own ManualDefaultsViewModel scoped to the sheet lifetime.
class ManualDefaultsSheet extends StatelessWidget {
  const ManualDefaultsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final settingsVm = context.read<SettingsViewModel>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            ManualDefaultsViewModel(initialPrefs: settingsVm.prefs),
        child: const ManualDefaultsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManualDefaultsViewModel>(
      builder: (ctx, vm, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _DragHandle(),
                _SheetHeader(
                  onClose: () => Navigator.of(ctx).pop(),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    children: [
                      _SheetSectionLabel('Default Project'),
                      const SizedBox(height: 8),
                      _ProjectSearchField(vm: vm),
                      const SizedBox(height: 8),
                      _ProjectPickerList(vm: vm),
                      const SizedBox(height: 24),
                      _SheetSectionLabel('Default Activity'),
                      const SizedBox(height: 8),
                      _ActivityDropdown(vm: vm),
                      const SizedBox(height: 24),
                      _SheetSectionLabel('Work Day Start Time'),
                      const SizedBox(height: 8),
                      _TimePickerTile(vm: vm),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                _ActionBar(vm: vm),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
            size: 18,
            color: AppColors.brandOrange,
          ),
          const SizedBox(width: 10),
          Text(
            'Set Smart Defaults',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  final String text;
  const _SheetSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class _ProjectSearchField extends StatefulWidget {
  final ManualDefaultsViewModel vm;
  const _ProjectSearchField({required this.vm});

  @override
  State<_ProjectSearchField> createState() => _ProjectSearchFieldState();
}

class _ProjectSearchFieldState extends State<_ProjectSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.vm.searchProjects,
      decoration: InputDecoration(
        hintText: 'Search projects…',
        prefixIcon: Icon(
          PhosphorIcons.magnifyingGlass(),
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  _controller.clear();
                  widget.vm.searchProjects('');
                },
              )
            : null,
      ),
    );
  }
}

class _ProjectPickerList extends StatelessWidget {
  final ManualDefaultsViewModel vm;
  const _ProjectPickerList({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = vm.filteredProjects;

    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('No projects found',
              style: theme.textTheme.bodySmall),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 196),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: projects.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
          itemBuilder: (_, i) {
            final project = projects[i];
            final selected = project.id == vm.selectedProjectId;
            return ListTile(
              dense: true,
              selected: selected,
              selectedTileColor: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.5),
              leading: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selected
                      ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                      : PhosphorIcons.circle(PhosphorIconsStyle.regular),
                  key: ValueKey(selected),
                  size: 18,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              title: Text(
                project.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? theme.colorScheme.primary : null,
                ),
              ),
              trailing: project.statusLabel != null
                  ? Text(
                      project.statusLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              onTap: () =>
                  selected ? vm.clearProject() : vm.selectProject(project),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityDropdown extends StatelessWidget {
  final ManualDefaultsViewModel vm;
  const _ActivityDropdown({required this.vm});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: vm.selectedActivityId,
      hint: const Text('Select activity…'),
      decoration: const InputDecoration(),
      borderRadius: BorderRadius.circular(12),
      items: vm.activities
          .map(
            (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
          )
          .toList(),
      onChanged: (id) {
        if (id == null) return;
        final activity = vm.activities.firstWhere((a) => a.id == id);
        vm.selectActivity(activity);
      },
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final ManualDefaultsViewModel vm;
  const _TimePickerTile({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTime = vm.selectedStartTime != null;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final parts = (vm.selectedStartTime ?? '07:00').split(':');
        final initial = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) {
          final formatted =
              '${picked.hour.toString().padLeft(2, '0')}:'
              '${picked.minute.toString().padLeft(2, '0')}';
          vm.selectStartTime(formatted);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasTime
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: hasTime ? 1.5 : 1,
          ),
          color: hasTime
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.clock(
                hasTime
                    ? PhosphorIconsStyle.fill
                    : PhosphorIconsStyle.regular,
              ),
              size: 20,
              color: hasTime
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vm.selectedStartTime ?? 'Tap to set start time',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: hasTime
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      hasTime ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (hasTime)
              GestureDetector(
                onTap: vm.clearStartTime,
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Text(
                'Set',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final ManualDefaultsViewModel vm;
  const _ActionBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.read<SettingsViewModel>();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    vm.isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: vm.isSaving ? null : () => _save(context, vm, settingsVm),
                child: vm.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    ManualDefaultsViewModel sheetVm,
    SettingsViewModel settingsVm,
  ) async {
    sheetVm.setSaving();
    await settingsVm.saveManualDefaults(
      projectId: sheetVm.selectedProjectId,
      projectName: sheetVm.selectedProjectName,
      activityId: sheetVm.selectedActivityId,
      activityName: sheetVm.selectedActivityName,
      workStartTime: sheetVm.selectedStartTime,
    );
    sheetVm.setSaved();
    if (context.mounted) Navigator.of(context).pop();
  }
}
