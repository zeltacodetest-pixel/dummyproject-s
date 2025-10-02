class AccountResult {
  const AccountResult({required this.accountId});

  final String accountId;
}

enum AccountError { invalidCredentials, offline }

class AccountException implements Exception {
  AccountException(this.error, this.message);

  final AccountError error;
  final String message;

  @override
  String toString() => 'AccountException($error, $message)';
}

class AccountService {
  bool _connectionAvailable = true;

  void setConnectionAvailable(bool value) {
    _connectionAvailable = value;
  }

  Future<AccountResult> signIn({
    required String emailOrPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _ensureConnection();
    if (password.trim().length < 6) {
      throw AccountException(
        AccountError.invalidCredentials,
        'Invalid password. Please try again.',
      );
    }
    return AccountResult(accountId: emailOrPhone.trim());
  }

  Future<AccountResult> createAccount({
    required String emailOrPhone,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _ensureConnection();
    if (otp.trim().length != 6) {
      throw AccountException(
        AccountError.invalidCredentials,
        'Invalid code. Please check the digits and try again.',
      );
    }
    return AccountResult(accountId: emailOrPhone.trim());
  }

  void _ensureConnection() {
    if (!_connectionAvailable) {
      throw AccountException(
        AccountError.offline,
        'Check your connection and try again.',
      );
    }
  }
}
