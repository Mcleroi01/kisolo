import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final VoidCallback onNext;

  const FeedbackScreen({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.onNext,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de scale pour l'apparition
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Animation de bounce pour l'icône
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    // Démarrer les animations
    _scaleController.forward();
    _bounceController.forward();

    // Animation automatique après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onNext();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icône de feedback animée
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -50 * (1 - _bounceAnimation.value)),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: widget.isCorrect
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.isCorrect
                                      ? AppColors.successGreen
                                      : AppColors.errorRed).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isCorrect ? Icons.check : Icons.close,
                              size: 60,
                              color: AppColors.pureWhite,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Message de feedback
                    Text(
                      widget.isCorrect
                          ? 'Excellent !'
                          : 'Pas tout à fait...',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: widget.isCorrect
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Réponse correcte
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isCorrect
                              ? AppColors.successGreen.withOpacity(0.3)
                              : AppColors.errorRed.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Réponse correcte:',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.correctAnswer,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Explication
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBeige,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: AppColors.accentOrange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Explication:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.explanation,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bouton continuer (optionnel)
                    if (widget.isCorrect) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+10 XP',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Indicateur de progression automatique
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue automatiquement...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
