class ProcessingResult {
  ProcessingResult({
    required this.summary,
    required this.conditions,
    required this.modelVersion,
  });

  final String summary;
  final List<String> conditions;
  final String modelVersion;
}

class ProcessingService {
  String get modelVersion => 'v0.1-local';

  Future<ProcessingResult> processCaptureSet(List<String> imagePaths) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return ProcessingResult(
      summary: imagePaths.isEmpty
          ? 'No captures yet — start a new scan to see insights.'
          : 'Preliminary results ready to review.',
      conditions: imagePaths.isEmpty
          ? const <String>[]
          : const <String>['Dandruff — Moderate', 'Irritation — Mild'],
      modelVersion: modelVersion,
    );
  }
}
