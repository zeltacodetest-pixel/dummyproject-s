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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ready for a new scan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'This prototype simulates the capture flow and stores the output locally to honor the offline-first approach.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleSimulatedCapture,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_isProcessing ? 'Processing…' : 'Simulate capture set'),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.teal.shade700),
              ),
            if (_lastConditions != null && _lastConditions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _lastConditions!
                      .map(
                        (String condition) => Text(
                          '• $condition',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
