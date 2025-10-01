import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/users/services/auth_service.dart';



// Modèle de Progrès simulé (à remplacer par la connexion réelle)
class Progress {
  final int currentLessonIndex;
  final int totalLessons;
  final double dailyProgress;

  const Progress({
    required this.currentLessonIndex,
    required this.totalLessons,
    required this.dailyProgress,
  });
}

// --- REMARQUE: J'ai converti en StatefulWidget pour gérer l'état (déconnexion/chargement) ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final Progress _mockProgress = const Progress(
    currentLessonIndex: 8,
    totalLessons: 20,
    dailyProgress: 0.75,
  );

  // Fonction de déconnexion simulée
  void _logout() async {

    if (mounted) {
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le code pour obtenir le nom d'affichage de l'utilisateur reste
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      // Retourner à l'écran de connexion si non authentifié
      return const Center(child: Text("Veuillez vous connecter."));
    }

    final displayName = currentUser.userMetadata?['display_name'] ??
        currentUser.userMetadata?['name'] ??
        currentUser.userMetadata?['first_name'] ??
        _mockUser.name; // Fallback sur le nom mocké

    return Scaffold(
      appBar: AppBar(
        // Remplacement de CustomAppBar par un AppBar standard avec action de déconnexion
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      backgroundColor: AppColors.cardBackground, // Fond légèrement différent
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // 1. Carte de profil principal
            _buildProfileCard(displayName, _mockUser, _mockProgress),

            const SizedBox(height: 32),

            // 2. Section Badges
            _buildBadgesSection(_mockUser),

            const SizedBox(height: 32),

            // 3. Barre de progression de la leçon
            _buildLessonProgressSection(_mockProgress),

            const SizedBox(height: 32),

            // 4. Historique des leçons
            _buildRecentActivitySection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGETS DÉDIÉS
  // -------------------------------------------------------------------

  // --- WIDGET 1: Carte de profil principal ---
  Widget _buildProfileCard(String displayName, User user, Progress progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, Color(0xFFE55D3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(40),
                ),
                // Utilisez un widget simple si l'asset n'est pas disponible, ou assurez-vous de l'inclure.
                child: const Icon(Icons.person_2_rounded,
                    size: 48, color: AppColors.accentOrange),
                // Si l'asset est disponible: child: Image.asset('assets/images/profile-man.png'),
              ),

              const SizedBox(width: 20),

              // Nom et niveau
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.pureWhite,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Niveau ${user.currentLevel} - Intermédiaire',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pureWhite,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Statistiques en ligne (XP et Série)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // XP Total
              _buildStatColumn(
                '${user.totalXP}',
                'XP Total 🌟',
                AppColors.pureWhite,
              ),

              // Séparateur vertical
              Container(
                  width: 1,
                  height: 40,
                  color: AppColors.pureWhite.withOpacity(0.3)),

              // Série de jours
              _buildStatColumn(
                '${user.streakDays} Jours',
                'Série 🔥',
                AppColors.pureWhite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET 2: Section Badges ---
  Widget _buildBadgesSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges et Récompenses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: user.badges.map((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    badge,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET 3: Barre de progression de la leçon ---
  Widget _buildLessonProgressSection(Progress progress) {
    final double percentValue =
        progress.currentLessonIndex / progress.totalLessons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression de la Leçon',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlack.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leçon ${progress.currentLessonIndex} / ${progress.totalLessons}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '${(percentValue * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percentValue,
                minHeight: 10,
                backgroundColor: AppColors.secondaryBeige,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentOrange,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET 4: Historique des leçons (Activité récente) ---
  Widget _buildRecentActivitySection() {
    final lessons = [
      {
        'title': 'Leçon 8 - Salutations',
        'status': 'Complétée avec succès',
        'color': AppColors.successGreen
      },
      {
        'title': 'Leçon 7 - Nombres',
        'status': 'Complétée avec succès',
        'color': AppColors.successGreen
      },
      {
        'title': 'Leçon 6 - Couleurs',
        'status': 'Révison nécessaire',
        'color': AppColors.accentOrange
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final color = lesson['color'] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title'] as String,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.primaryBlack,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        Text(
                          lesson['status'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withOpacity(0.5),
                    size: 24,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET UTILITAIRE: Colonne de statistiques ---
  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
