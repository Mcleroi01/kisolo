import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBeige, // Utiliser le Scaffold
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre de navigation/Profil (Entête)
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
              child: _TopBar(),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Carte d'Action Principale (Leçon en cours)
                    _buildMainActionCard(context),
                    
                    const SizedBox(height: 32),
                    
                    // 3. Sélecteur de Langue (Simplifié/Amélioré visuellement)
                    _buildLanguageSelector(),
                    
                    const SizedBox(height: 32),
                    
                    // 4. Section Niveaux/Thèmes
                    Text(
                      "Centre ya intérêt", // "Centre d'intérêt"
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryBlack,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    
                    // 5. Cartes des Thèmes (avec un empilement moins vertical pour un meilleur aperçu)
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

  // --- WIDGET AMÉLIORÉ: Barre de Progression et Profil (inspiré du lesson_screen) ---
  Widget _TopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Avatar de Profil
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.accentOrange, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.accentOrange,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Barre de progression globale
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texte de progression
                Text(
                  'Progression globale',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Barre de progression
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: 0.65, // Progression globale simulée à 65%
                  backgroundColor: AppColors.secondaryBeige.withOpacity(0.5),
                  progressColor: AppColors.accentOrange,
                  barRadius: const Radius.circular(10),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Jours de Série (Streak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Text(
                  '14',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET AMÉLIORÉ: Carte d'Action Principale ---
  Widget _buildMainActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(25),
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
          // Titre de la carte
          Row(
            children: [
              const Icon(Icons.school_rounded, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Titre ya leçon ya Lelo', // "Titre de la leçon d'aujourd'hui"
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Nom de la leçon en cours
          Text(
            'Ba Losako mpe Koloba Malamu (Leçon 1)',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryBlack,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 16),

          // Barre de progression (simulée)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression : 40% Complété',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: 0.4, // Simuler 40% de progression
            backgroundColor: AppColors.secondaryBeige,
            progressColor: AppColors.accentOrange,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Bouton d'Action
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/lessons'), // Action principale
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
              label: const Text(
                'Kobanda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
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

  // --- WIDGET AMÉLIORÉ: Sélecteur de Langue (plus d'impact) ---
  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Langue ya kokabola",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildFlagCircle('🇵🇹', isSelected: true), // Portugais (Langue cible)
            _buildFlagCircle('🇫🇷', isSelected: false), // Français (Langue maternelle)
            _buildFlagCircle('🇪🇸', isSelected: false), 
            _buildFlagCircle('🇮🇹', isSelected: false),
            // Utiliser un bouton pour "Plus"
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pureWhite,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 30),
            ),
          ],
        ),
      ],
    );
  }

  // Laisse _buildFlagCircle, _buildTopicCardsStack, et _buildTopicCardWithIllustration tels quels, car leur design est déjà bon.
  
  Widget _buildFlagCircle(String flag, {required bool isSelected}) {
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          flag,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
  
  Widget _buildTopicCardsStack(BuildContext context) {
    const double cardHeight = 140;
    const double cardOffset = 40; // Réduit l'empilement pour montrer plus rapidement le contenu

    return SizedBox(
      // Hauteur ajustée
      height: cardHeight + cardOffset * 2, 
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Carte 3: en bas
          Positioned(
            top: cardOffset * 2, 
            child: _buildTopicCardWithIllustration(
              context: context,
              color: const Color.fromARGB(255, 146, 255, 144),
              title: 'Bilei mpe Kolamba',
              description:
                  'Yekola ba recettes na ba traditions culinaire na minoko ya bapaya',
              illustration: _buildPizzaIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),
          // Carte 2: au milieu
          Positioned(
            top: cardOffset * 1,
            child: _buildTopicCardWithIllustration(
              context: context,
              color: const Color.fromARGB(255, 144, 178, 255),
              title: 'Masano mpe Misala',
              description:
                  'Maîtriser terminologie ya sports na minoko ya bapaya',
              illustration: _buildBasketballIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),
          // Carte 1: en haut et visible en entier
          Positioned(
            top: 0,
            child: _buildTopicCardWithIllustration(
              context: context,
              color: const Color.fromARGB(255, 253, 137, 168),
              title: 'Kosala mibembo',
              description: 'Panza vocabulaire na yo pona ba aventures na poto',
              illustration: _buildGlobeIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCardWithIllustration({
    required BuildContext context,
    required Color color,
    required String title,
    required String description,
    required Widget illustration,
    required Alignment illustrationAlignment,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - (24.0 * 2);

    return Container(
      width: cardWidth,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          color: AppColors.pureWhite,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5), // Ombre plus colorée
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Illustration simplifiée pour ne pas dépendre des assets
          Positioned(
            right: 15,
            bottom: -5, // Déborde légèrement
            child: Opacity(
              opacity: 0.8,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: illustration, // Remplacez par une icône ou une image d'asset si disponible
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Remplacements d'illustrations par de simples icônes pour éviter les erreurs d'assets
  Widget _buildGlobeIllustration() => const Center(child: Icon(Icons.public_rounded, size: 50, color: AppColors.pureWhite));
  Widget _buildBasketballIllustration() => const Center(child: Icon(Icons.sports_basketball_rounded, size: 50, color: AppColors.pureWhite));
  Widget _buildPizzaIllustration() => const Center(child: Icon(Icons.ramen_dining_rounded, size: 50, color: AppColors.pureWhite));
}