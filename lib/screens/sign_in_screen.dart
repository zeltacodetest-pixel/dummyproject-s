import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../services/app_dependencies.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.onAccountLinked,
    required this.onSkip,
  });

  final Future<void> Function(String accountId) onAccountLinked;
  final Future<void> Function() onSkip;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final TextEditingController _signInContactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _createContactController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInContactController.dispose();
    _passwordController.dispose();
    _createContactController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final AccountService accountService =
        AppDependencies.of(context).accountService;
    setState(() {
      _errorMessage = null;
    });

    if (_tabController.index == 0) {
      if (!(_signInFormKey.currentState?.validate() ?? false)) {
        return;
      }
      setState(() {
        _isSubmitting = true;
      });
      try {
        final AccountResult result = await accountService.signIn(
          emailOrPhone: _signInContactController.text,
          password: _passwordController.text,
        );
        await widget.onAccountLinked(result.accountId);
      } on AccountException catch (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error.message;
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else {
      if (!(_createFormKey.currentState?.validate() ?? false)) {
        return;
      }
      setState(() {
        _isSubmitting = true;
      });
      try {
        final AccountResult result = await accountService.createAccount(
          emailOrPhone: _createContactController.text,
          otp: _otpController.text,
        );
        await widget.onAccountLinked(result.accountId);
      } on AccountException catch (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error.message;
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  String? _validateContact(String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your email or phone number.';
    }
    final bool looksLikeEmail = trimmed.contains('@');
    final bool looksLikePhone =
        trimmed.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;
    if (!looksLikeEmail && !looksLikePhone) {
      return 'Enter a valid email or phone number.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    if (value == null || value.trim().length != 6) {
      return 'Enter the 6-digit code sent to you.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync your scans'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Create an account to sync your history across devices. You can also keep everything on this phone.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
                indicatorColor: theme.colorScheme.primary,
                tabs: const <Tab>[
                  Tab(text: 'Sign in'),
                  Tab(text: 'Create account'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Form(
                      key: _signInFormKey,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 24),
                        children: <Widget>[
                          TextFormField(
                            controller: _signInContactController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email or phone',
                            ),
                            validator: _validateContact,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: _validatePassword,
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _createFormKey,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 24),
                        children: <Widget>[
                          TextFormField(
                            controller: _createContactController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email or phone',
                            ),
                            validator: _validateContact,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'One-time code',
                              hintText: '6-digit code',
                            ),
                            validator: _validateOtp,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We send a quick code to verify your device. Enter the 6 digits to finish setting up your account.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        await widget.onSkip();
                      },
                child: const Text('Continue without account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
