import 'package:flutter/material.dart';

import '../services/app_dependencies.dart';
import '../services/legal_content_service.dart';
import '../widgets/legal_document_sheet.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onContinue});

  final Future<void> Function() onContinue;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<_OnboardingSlide> _slides = const <_OnboardingSlide>[
    _OnboardingSlide(
      icon: Icons.spa_outlined,
      title: 'Understand your scalp',
      description:
          'HairGuard provides guided captures to spot changes in your scalp over time.',
    ),
    _OnboardingSlide(
      icon: Icons.shield_moon_outlined,
      title: 'Privacy-first design',
      description:
          'All analysis runs on your device. Nothing uploads unless you decide to share it.',
    ),
    _OnboardingSlide(
      icon: Icons.health_and_safety_outlined,
      title: 'Not a diagnosis',
      description:
          'HairGuard offers screening guidance. If symptoms worsen, please see a healthcare professional.',
    ),
    _OnboardingSlide(
      icon: Icons.lightbulb_outline,
      title: 'Capture tips',
      description:
          'Use bright, even lighting, hold steady, and follow the guides for top, side, and back views.',
    ),
  ];

  int _currentPage = 0;
  bool _consentGiven = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_consentGiven || _isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    await widget.onContinue();
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  Future<void> _openDocument(LegalDocumentType type, String title) async {
    final LegalContentService legalContentService =
        AppDependencies.of(context).legalContentService;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => LegalDocumentSheet(
        title: title,
        loader: () => legalContentService.fetchDocument(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Welcome to HairGuard', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final _OnboardingSlide slide = _slides[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(slide.icon, size: 72, color: theme.colorScheme.primary),
                              const SizedBox(height: 24),
                              Text(
                                slide.title,
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide.description,
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(_slides.length, (int index) {
                        final bool isActive = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 20 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => _openDocument(LegalDocumentType.terms, 'Terms of Use'),
                          child: const Text('Terms of Use'),
                        ),
                        TextButton(
                          onPressed: () => _openDocument(LegalDocumentType.privacy, 'Privacy Policy'),
                          child: const Text('Privacy Policy'),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _consentGiven,
                      onChanged: (bool? value) {
                        setState(() {
                          _consentGiven = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I understand that HairGuard runs on my device and offers guidance, not a diagnosis.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _consentGiven && !_isSubmitting ? _handleContinue : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

