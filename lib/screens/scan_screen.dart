import 'package:flutter/material.dart';

import '../services/app_dependencies.dart';
import '../services/offline_data_store.dart';
import '../services/permission_service.dart';
import '../services/processing_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const List<String> _checklistItems = <String>[
    'Find bright, even lighting (avoid harsh shadows).',
    'Clean your camera lens for a clear view.',
    'Remove hats, accessories, or hair toppers.',
    'Have someone help with the back view if available.',
  ];

  late final List<bool> _checklistSelections =
      List<bool>.filled(_checklistItems.length, false);
  bool _isReadyForCapture = false;
  bool _isProcessing = false;
  String? _statusMessage;
  List<String>? _lastConditions;

  Future<void> _handleSimulatedCapture() async {
    final PermissionService permissionService =
        AppDependencies.of(context).permissionService;
    final OfflineDataStore store = AppDependencies.of(context).offlineDataStore;
    final ProcessingService processingService =
        AppDependencies.of(context).processingService;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Checking camera permission...';
    });

    final PermissionStatus status = await permissionService.ensureCameraPermission();
    if (!mounted) return;

    if (status != PermissionStatus.granted) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Camera permission required to continue.';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Processing locally...';
    });

    final ProcessingResult result =
        await processingService.processCaptureSet(const <String>['top', 'side', 'back']);

    if (!mounted) return;

    await store.saveSession(
      ScanSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        summary: result.summary,
      ),
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _lastConditions = result.conditions;
      _statusMessage = 'Session stored locally (${result.modelVersion}).';
    });
  }

  bool get _allChecklistComplete =>
      _checklistSelections.every((bool value) => value);

  void _toggleChecklistItem(int index, bool? value) {
    setState(() {
      _checklistSelections[index] = value ?? false;
    });
  }

  void _beginCapture() {
    setState(() {
      _isReadyForCapture = true;
      _statusMessage = null;
      _lastConditions = null;
    });
  }

  void _returnToPreparation() {
    setState(() {
      _isReadyForCapture = false;
      _isProcessing = false;
      _statusMessage = null;
      _lastConditions = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isReadyForCapture
              ? _CaptureSimulation(
                  key: const ValueKey<String>('capture'),
                  isProcessing: _isProcessing,
                  statusMessage: _statusMessage,
                  lastConditions: _lastConditions,
                  onSimulate: _handleSimulatedCapture,
                  onBack: _returnToPreparation,
                )
              : _PreparationChecklist(
                  key: const ValueKey<String>('prep'),
                  checklistItems: _checklistItems,
                  selections: _checklistSelections,
                  allComplete: _allChecklistComplete,
                  onToggle: _toggleChecklistItem,
                  onBegin: _beginCapture,
                ),
        ),
      ),
    );
  }
}

class _PreparationChecklist extends StatelessWidget {
  const _PreparationChecklist({
    super.key,
    required this.checklistItems,
    required this.selections,
    required this.allComplete,
    required this.onToggle,
    required this.onBegin,
  });

  final List<String> checklistItems;
  final List<bool> selections;
  final bool allComplete;
  final void Function(int index, bool? value) onToggle;
  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Preparation checklist', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Complete these quick steps before capturing your top, side, and back views.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: <Widget>[
              for (int index = 0; index < checklistItems.length; index++)
                CheckboxListTile(
                  value: selections[index],
                  onChanged: (bool? value) => onToggle(index, value),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(checklistItems[index]),
                ),
              const SizedBox(height: 12),
              Text('Sample framing', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: const <Widget>[
                  _SampleFrame(label: 'Top view'),
                  SizedBox(width: 12),
                  _SampleFrame(label: 'Side view'),
                  SizedBox(width: 12),
                  _SampleFrame(label: 'Back view'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: allComplete ? onBegin : null,
            child: const Text('Begin'),
          ),
        ),
      ],
    );
  }
}

class _SampleFrame extends StatelessWidget {
  const _SampleFrame({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureSimulation extends StatelessWidget {
  const _CaptureSimulation({
    super.key,
    required this.isProcessing,
    required this.statusMessage,
    required this.lastConditions,
    required this.onSimulate,
    required this.onBack,
  });

  final bool isProcessing;
  final String? statusMessage;
  final List<String>? lastConditions;
  final Future<void> Function() onSimulate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isProcessing ? null : onBack,
              tooltip: 'Back to checklist',
            ),
            Text('Guided capture (simulated)', style: theme.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ll walk through each angle and process everything locally. Use this simulation until the full capture flow is ready.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: isProcessing ? null : onSimulate,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(isProcessing ? 'Processing…' : 'Simulate capture set'),
        ),
        const SizedBox(height: 16),
        if (statusMessage != null)
          Text(
            statusMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.teal.shade700),
          ),
        if (lastConditions != null && lastConditions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lastConditions!
                  .map(
                    (String condition) => Text(
                      '• $condition',
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
