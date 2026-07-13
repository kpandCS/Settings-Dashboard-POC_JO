import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../model/activity.dart';
import '../../../model/project.dart';
import '../../../viewmodel/time_registration_viewmodel.dart';

Future<void> showVoiceTimeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const VoiceTimeSheet(),
  );
}

/// Bottom sheet for logging time by voice: a mic button backed by on-device
/// speech recognition, a type-instead fallback, and an editable preview of
/// the parsed project / activity / hours before confirming.
class VoiceTimeSheet extends StatelessWidget {
  const VoiceTimeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeRegistrationViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceBase,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Voice Time Registration', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Try: "Log 2 hours on Strand Bolig for concrete work"',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _MicButton(vm: vm),
                const SizedBox(height: 12),
                Text(
                  _statusLabel(vm),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (vm.transcript.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Text('"${vm.transcript}"'),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Or type a command',
                    hintText: 'e.g. 2.5 hours plumbing at Lofoten Hytte',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: vm.updateManualText,
                ),
                if (vm.parseResult != null) ...[
                  const SizedBox(height: 20),
                  _ParsePreview(vm: vm),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: (vm.parseResult?.isComplete ?? false)
                            ? () {
                                vm.confirm();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Time logged')));
                              }
                            : null,
                        child: const Text('Log Time'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(TimeRegistrationViewModel vm) {
    switch (vm.status) {
      case VoiceRegistrationStatus.listening:
        return 'Listening…';
      case VoiceRegistrationStatus.reviewing:
        return 'Review the details below and confirm.';
      case VoiceRegistrationStatus.unavailable:
        return vm.errorMessage ?? 'Speech recognition unavailable — type a command instead.';
      case VoiceRegistrationStatus.idle:
        return 'Tap the microphone to speak.';
    }
  }
}

class _MicButton extends StatelessWidget {
  final TimeRegistrationViewModel vm;
  const _MicButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    final listening = vm.status == VoiceRegistrationStatus.listening;
    return Center(
      child: GestureDetector(
        onTap: listening ? vm.stopListening : vm.startListening,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: listening ? AppColors.errorRed : AppColors.brandOrange,
          ),
          child: Icon(
            listening ? PhosphorIcons.stop(PhosphorIconsStyle.fill) : PhosphorIcons.microphone(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _ParsePreview extends StatefulWidget {
  final TimeRegistrationViewModel vm;
  const _ParsePreview({required this.vm});

  @override
  State<_ParsePreview> createState() => _ParsePreviewState();
}

class _ParsePreviewState extends State<_ParsePreview> {
  late final TextEditingController _hoursController;
  final _hoursFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(text: _formatHours(widget.vm.parseResult?.hours));
  }

  @override
  void didUpdateWidget(covariant _ParsePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = _formatHours(widget.vm.parseResult?.hours);
    if (!_hoursFocusNode.hasFocus && _hoursController.text != text) {
      _hoursController.text = text;
    }
  }

  String _formatHours(double? hours) {
    if (hours == null) return '';
    return hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toString();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _hoursFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.vm.parseResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Project>(
          value: result.project,
          decoration: const InputDecoration(labelText: 'Project'),
          items: Project.mockProjects().map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
          onChanged: (p) {
            if (p != null) widget.vm.overrideProject(p);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Activity>(
          value: result.activity,
          decoration: const InputDecoration(labelText: 'Activity'),
          items: Activity.mockActivities().map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
          onChanged: (a) {
            if (a != null) widget.vm.overrideActivity(a);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _hoursController,
          focusNode: _hoursFocusNode,
          decoration: const InputDecoration(labelText: 'Hours'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            final parsed = double.tryParse(value.replaceAll(',', '.'));
            if (parsed != null) widget.vm.overrideHours(parsed);
          },
        ),
      ],
    );
  }
}
