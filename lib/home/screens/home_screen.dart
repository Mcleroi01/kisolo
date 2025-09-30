import 'package:flutter/material.dart';
import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/lessons/screens/lesson_screen.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:kisolo/widgets/appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Carlo Musongela',
        subtitle: 'Niveau ya 3',
        logoAssetPath: 'assets/images/profile-man.png',
      ),
      backgroundColor:
          AppColors.pureWhite, // Assurez-vous que c'est le bon blanc/beige
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligner le contenu à gauche
              children: [
                // Illustration placeholder
                Container(
                  width: double.infinity,
                  height: 280,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentOrange, Color(0xFFE55D3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mikolo 14 na molongo!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.secondaryBeige,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Section des leçons - Scroll horizontal
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Leçon 1 - Salutations (actuelle)
                            _buildLessonCard(
                              context: context,
                              icon: Icons.waving_hand,
                              title: 'Ba Losako',
                              isCurrent: true,
                              lessonNumber: 1,
                            ),

                            const SizedBox(width: 12),

                            // Leçon 2 - Nombres
                            _buildLessonCard(
                              context: context,
                              icon: Icons.looks_one,
                              title: 'Mituya',
                              isCurrent: false,
                              lessonNumber: 2,
                            ),

                            const SizedBox(width: 12),

                            // Leçon 3 - Couleurs
                            _buildLessonCard(
                              context: context,
                              icon: Icons.color_lens,
                              title: 'Ba couleurs',
                              isCurrent: false,
                              lessonNumber: 3,
                            ),

                            const SizedBox(width: 12),

                            // Leçon 4 - Famille
                            _buildLessonCard(
                              context: context,
                              icon: Icons.family_restroom,
                              title: 'Libota',
                              isCurrent: false,
                              lessonNumber: 4,
                            ),

                            const SizedBox(width: 12),

                            // Leçon 5 - Nourriture
                            _buildLessonCard(
                              context: context,
                              icon: Icons.restaurant,
                              title: 'Bilei',
                              isCurrent: false,
                              lessonNumber: 5,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Boutons d'action
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Récupérer l'ID de l'utilisateur connecté
                                  final userId = SupabaseConfig.client.auth.currentUser?.id;
                                  
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Veuillez vous connecter')),
                                    );
                                    return;
                                  }

                                  // Récupérer la dernière leçon de l'utilisateur
                                  final lastLesson = await UserLessonService.getLastUserLesson(userId);
                                  
                                  if (lastLesson != null && lastLesson['levelId'] != null && lastLesson['lessonId'] != null) {
                                    // Naviguer vers la dernière leçon
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LessonScreen(
                                            levelId: lastLesson['levelId'] as String,
                                            lessonId: lastLesson['lessonId'] as String,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Si aucune leçon n'est trouvée, afficher un message
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Aucune leçon trouvée. Commencez une nouvelle leçon.'),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pureWhite,
                                foregroundColor: AppColors.primaryBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Kobanda',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildLanguageFlags(),
                const SizedBox(height: 32),

                // Texte d'accroche "Centre d'interet"
                const Text(
                  "Centre ya intérêt",
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    fontSize: 18, // Taille ajustée
                  ),
                  textAlign: TextAlign.start, // Aligné à gauche
                ),

                const SizedBox(height: 16),

                // --- SECTION DES CARTES AVEC SUPERPOSITION ---
                _buildTopicCardsStack(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour la section des drapeaux
  Widget _buildLanguageFlags() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceAround, // Espacer les drapeaux uniformément
      children: <Widget>[
        _buildFlagCircle('🇺🇸', isSelected: false),
        _buildFlagCircle('🇪🇸', isSelected: true), // Espagne sélectionnée
        _buildFlagCircle('🇮🇹', isSelected: false),
        _buildFlagCircle('🇩🇪', isSelected: false),
        _buildFlagCircle('🇫🇷', isSelected: false),
      ],
    );
  }

  // Widget pour un cercle de drapeau individuel
  Widget _buildFlagCircle(String flag, {required bool isSelected}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: isSelected
            ? Border.all(
                color: Colors.orange, width: 3) // Bordure orange si sélectionné
            : Border.all(
                color: Colors.grey.shade300,
                width: 1), // Bordure fine si non sélectionné
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
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
          style: const TextStyle(fontSize: 30), // Taille de l'emoji drapeau
        ),
      ),
    );
  }

  // --- NOUVEAU WIDGET: Conteneur de la Stack des cartes ---
  Widget _buildTopicCardsStack(BuildContext context) {
    // La hauteur totale doit être la hauteur de la carte de base (140)
    // plus le décalage cumulé des cartes empilées.
    // 140 + 15 + 15 = 170 (pour compenser les décalages visuels)
    const double cardHeight = 140;
    const double cardOffset = 15; // Décalage pour l'effet de superposition

    return SizedBox(
      height: cardHeight + cardOffset * 15, // 140 + 15 + 15 = 170
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Carte "Travelling" (Rose - position de base: 0)
          Positioned(
            top: 0,
            child: _buildTopicCardWithIllustration(
              context: context,
              color: const Color.fromARGB(
                  255, 253, 137, 168), // Rose/Saumon ajusté
              title: 'Kosala mibembo',
              description: 'Panza vocabulaire na yo pona ba aventures na poto',
              illustration: _buildGlobeIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),
          // 3. Carte "Food and Cooking" (Vert - position de base: décalage maximum)

          // 2. Carte "Sport and Activities" (Bleu - position: décalage moyen)
          Positioned(
            top: cardOffset * 7, // 15
            child: _buildTopicCardWithIllustration(
              context: context,
              color: const Color.fromARGB(
                  255, 144, 178, 255), // Bleu clair/Mauve ajusté
              title: 'Masano mpe Misala',
              description:
                  'Maîtriser terminologie ya sports na minoko ya bapaya',
              illustration: _buildBasketballIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),

          Positioned(
            top: cardOffset * 14, // 30
            child: _buildTopicCardWithIllustration(
              context: context,
              color:
                  const Color.fromARGB(255, 146, 255, 144), // Vert vif ajusté
              title: 'Bilei mpe Kolamba',
              description:
                  'Yekola ba recettes na ba traditions culinaire na minoko ya bapaya',
              illustration: _buildPizzaIllustration(),
              illustrationAlignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS D'ILLUSTRATION (Remplacer par vos assets réels) ---

  Widget _buildGlobeIllustration() {
    return SizedBox(
      width: 150,
      height: 150,
      // Assurez-vous que 'assets/images/globe.png' est déclaré dans pubspec.yaml
      child: Image.asset(
        'assets/images/globe.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildBasketballIllustration() {
    return SizedBox(
      width: 150,
      height: 150,
      // Assurez-vous que 'assets/images/basketball.png' est déclaré dans pubspec.yaml
      child: Image.asset(
        'assets/images/basketball.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPizzaIllustration() {
    return SizedBox(
      width: 150, // Plus grande pour la pizza
      height: 150,
      // Assurez-vous que 'assets/images/pizza.png' est déclaré dans pubspec.yaml
      child: Image.asset(
        'assets/images/pizza.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // --- Widget réutilisable pour la construction des cartes ---
  Widget _buildTopicCardWithIllustration({
    required BuildContext context,
    required Color color,
    required String title,
    required String description,
    required Widget illustration,
    required Alignment illustrationAlignment,
  }) {
    // Utiliser MediaQuery pour que la carte prenne toute la largeur disponible (moins le padding horizontal du Scaffold)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth -
        (24.0 * 2); // 24.0 * 2 est le padding horizontal du Padding parent

    return Container(
      width: cardWidth, // Utilise la largeur calculée
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          color: AppColors.pureWhite,
          width: 3,
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Contenu du texte
          Positioned(
            top: 20, // Ajustement vertical
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
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth:
                        200, // Limiter la largeur du texte pour laisser de la place à l'illustration
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Illustration superposée
          Positioned.fill(
            child: Align(
              alignment: illustrationAlignment,
              child: Padding(
                // Décale l'illustration légèrement vers le bas et la droite
                padding: const EdgeInsets.only(right: 15.0, bottom: 0.0),
                child: illustration,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isCurrent,
    required int lessonNumber,
  }) {
    // Reste de la fonction _buildLessonCard (inchangé)
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.secondaryBeige
            : AppColors.secondaryBeige.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.accentOrange
              : AppColors.accentOrange.withOpacity(0.3),
          width: isCurrent ? 3 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.accentOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar/Icône de la leçon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.accentOrange
                    : AppColors.accentOrange.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.pureWhite,
                  width: 2,
                )),
            child: Icon(
              icon,
              color: AppColors.pureWhite,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Titre de la leçon
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCurrent
                      ? AppColors.primaryBlack
                      : AppColors.textSecondary,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
