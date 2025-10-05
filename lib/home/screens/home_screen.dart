import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/widgets/unified_topbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBeige,
      body: SafeArea(
        child: Column(
          children: [
            // TopBar Unifié
            const UnifiedTopBar(showProgress: true),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte d'Action Principale
                    _buildMainActionCard(context),

                    const SizedBox(height: 32),

                    // Sélecteur de Langue
                    _buildLanguageSelector(),

                    const SizedBox(height: 32),

                    // Section Thèmes
                    Text(
                      "Centre ya intérêt",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlack,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),

                    _buildTopicCardsStack(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryBeige,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.pureWhite, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Leçon du jour',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Salutations et Politesse',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lessons'),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              label: const Text(
                'Kobanda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Langue cible",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFlagCircle('🇵🇹', label: 'PT', isSelected: true),
            _buildFlagCircle('🇫🇷', label: 'FR', isSelected: false),
            _buildFlagCircle('🇪🇸', label: 'ES', isSelected: false),
            _buildFlagCircle('🇮🇹', label: 'IT', isSelected: false),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pureWhite,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.textSecondary, size: 30),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagCircle(String flag,
      {required String label, required bool isSelected}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: isSelected
            ? Border.all(color: AppColors.accentOrange, width: 3)
            : Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.accentOrange.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Text(flag, style: const TextStyle(fontSize: 30)),
      ),
    );
  }

  Widget _buildTopicCardsStack(BuildContext context) {
    const double cardHeight = 140;
    const double cardOffset = 40;

    return SizedBox(
      height: cardHeight + cardOffset * 2,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: cardOffset * 2,
            child: _buildTopicCard(
              context,
              color: const Color.fromARGB(255, 146, 255, 144),
              title: 'Bilei mpe Kolamba',
              icon: Icons.restaurant_rounded,
            ),
          ),
          Positioned(
            top: cardOffset,
            child: _buildTopicCard(
              context,
              color: const Color.fromARGB(255, 144, 178, 255),
              title: 'Masano mpe Misala',
              icon: Icons.sports_basketball_rounded,
            ),
          ),
          Positioned(
            top: 0,
            child: _buildTopicCard(
              context,
              color: const Color.fromARGB(255, 253, 137, 168),
              title: 'Kosala mibembo',
              icon: Icons.public_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context, {
    required Color color,
    required String title,
    required IconData icon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (24.0 * 2);

    return Container(
      width: cardWidth,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.pureWhite, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          Icon(icon, size: 60, color: AppColors.pureWhite.withOpacity(0.8)),
        ],
      ),
    );
  }
}