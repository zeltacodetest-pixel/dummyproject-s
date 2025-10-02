enum LegalDocumentType { terms, privacy }

class LegalContentService {
  bool _simulateFailure = false;

  void setSimulateFailure(bool value) {
    _simulateFailure = value;
  }

  Future<String> fetchDocument(LegalDocumentType type) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_simulateFailure) {
      throw Exception('Unable to load document.');
    }

    switch (type) {
      case LegalDocumentType.terms:
        return 'HairGuard Terms of Use\n\nUse HairGuard responsibly. By continuing, you agree to local storage and on-device analysis.';
      case LegalDocumentType.privacy:
        return 'HairGuard Privacy Policy\n\nYour scans stay on this device unless you choose to share them.';
    }
  }
}
