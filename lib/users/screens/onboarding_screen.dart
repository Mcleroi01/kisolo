import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisolo/users/services/auth_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Onboarding steps data
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Boyei malamu na Kisolo',
      'subtitle': 'Yekola Portugais na ndenge ya kosepelisa uta na Lingala',
      'image': 'assets/images/basketball.png',
      'color': const Color(0xFFFF6B35),
    },
    {
      'title': 'Progression Personnalisée',
      'subtitle': 'Bolanda progrès na yo na système ya niveau na point',
      'image': 'assets/images/enjoy.png',
      'color': const Color(0xFFF7931E),
    },
    {
      'title': 'Bandá mobembo na yo',
      'subtitle': 'Kota mpo na kobomba bokoli na yo',
      'image': 'assets/images/globe.png',
      'color': const Color(0xFFE55D3A),
      'showAuthButton': true,
    },
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // Last step shows auth button directly, no action needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () async {
                      final success = await AuthService.signInWithProvider();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Erreur de connexion. Veuillez réessayer.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Koleka',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image
                          Container(
                            width: 200,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              step['image'] as String,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            step['title'] as String,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            step['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Progress indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _steps.length,
                              (index) => Container(
                                width: _currentStep == index ? 20 : 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _currentStep == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Next button or Auth button on last step
                          _currentStep == _steps.length - 1
                              ? ElevatedButton.icon(
                                  onPressed: () async {
                                    final success =
                                        await AuthService.signInWithProvider();
                                    if (!success && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Erreur de connexion. Veuillez réessayer.'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.login),
                                  label: const Text('Kota na Google'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: step['color'] as Color,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: step['color'] as Color,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Oyo elandi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
