import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/core/utils/app_colors.dart'; // Assurez-vous d'avoir ce fichier

// Simulation des couleurs manquantes pour cet exemple
abstract class AppColors {
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color pureWhite = Colors.white;
  static const Color primaryBlack = Color(0xFF1E1E1E);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  // PageController pour contrôler le PageView
  late final PageController _pageController;

  // Onboarding steps data
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Boyei malamu na Kisolo 🌍',
      'subtitle': 'Yekola Portugais na ndenge ya kosepelisa uta na Lingala.',
      'image': 'assets/images/basketball.png',
      'color': const Color(0xFFFF6B35),
    },
    {
      'title': 'Progression Personnalisée 🚀',
      'subtitle': 'Bolanda progrès na yo na système ya niveau na point mpo na kozala motivé.',
      'image': 'assets/images/enjoy.png',
      'color': const Color(0xFFF7931E),
    },
    {
      'title': 'Bandá mobembo na yo ✍️',
      'subtitle': 'Kota mpo na kobomba bokoli na yo mpe kokanga ba leçons ya suka.',
      'image': 'assets/images/globe.png',
      'color': const Color(0xFFE55D3A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fonction pour passer à l'étape suivante
  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  // Fonction pour la connexion/inscription
  void _handleAuthAction() async {
    // Dans l'étape finale, le bouton agit comme un bouton de connexion
    if (_currentStep == _steps.length - 1) {
      final success = await AuthService.signInWithProvider();
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Dans les étapes intermédiaires, le bouton passe à l'étape suivante
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Détermine la couleur de l'étape actuelle pour un design dynamique
    final currentStepColor = _steps[_currentStep]['color'] as Color;
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Utilisation du dégradé pour la couleur de fond
          gradient: LinearGradient(
            colors: [currentStepColor.withOpacity(0.9), currentStepColor.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Bouton 'Koleka' (Ignorer)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                  child: TextButton(
                    onPressed: _handleAuthAction, // Le bouton "Ignorer" a la même action que le bouton principal final
                    child: Text(
                      isLastStep ? 'Commencer' : 'Koleka',
                      style: const TextStyle(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenu principal (Image + Texte)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Espace pour l'image
                          _OnboardingImage(imagePath: step['image'] as String),
                          const SizedBox(height: 32),

                          // Titre
                          Text(
                            step['title'] as String,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pureWhite,
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Sous-titre
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.pureWhite.withOpacity(0.85),
                              fontFamily: 'Nunito',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicateurs de progression et Bouton principal
              _buildBottomControls(currentStepColor, isLastStep),
            ],
          ),
        ),
      ),
    );
  }

  // Widget séparé pour les indicateurs et le bouton d'action
  Widget _buildBottomControls(Color stepColor, bool isLastStep) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Indicateurs de progression (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentStep == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentStep == index
                      ? AppColors.pureWhite // Blanc pour le dot actif
                      : AppColors.pureWhite.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Bouton Principal
          SizedBox(
            width: double.infinity,
            height: 60,
            child: isLastStep
                ? _buildAuthButton(stepColor)
                : _buildNextButton(stepColor),
          ),
        ],
      ),
    );
  }

  // Bouton "Kota na Google" (Dernière étape)
  Widget _buildAuthButton(Color stepColor) {
    return OutlinedButton(
      onPressed: _handleAuthAction,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.primaryBlack,
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: AppColors.primaryBlack.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône Google (simulée) ou utilisez un package tiers pour l'icône réelle
          Image.asset(
            'assets/icons/google_icon.png', // À remplacer par votre asset réel
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.login,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Kota na Google',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  // Bouton "Oyo elandi" (Étapes intermédiaires)
  Widget _buildNextButton(Color stepColor) {
    return ElevatedButton(
      onPressed: _handleAuthAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: stepColor, // Couleur dynamique
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: AppColors.primaryBlack.withOpacity(0.1),
      ),
      child: const Text(
        'Oyo elandi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// Widget pour améliorer la présentation de l'image
class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Taille plus grande et flexible pour une présentation moderne
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      // Mettre l'image sur un fond blanc transparent pour la faire ressortir
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}