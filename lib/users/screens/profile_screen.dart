import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/users/model/users.dart';
import 'package:kisolo/widgets/appbar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kisolo/models/app_models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données de démonstration
    const user = User(
      id: '1',
      name: 'Kisolo User',
      avatar: '👩‍🎓',
      currentLevel: 3,
      totalXP: 1250,
      streakDays: 7,
      badges: ['Premier mot', 'Série de 5 jours', 'Leçon 10'],
    );

    final progress = Progress(
      currentLessonIndex: 8,
      totalLessons: 20,
      dailyProgress: 0.75,
      lastStudyDate: DateTime.now(),
    );

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Carlo Musongela',
        subtitle: 'Niveau ya 3',
        logoAssetPath: 'assets/images/profile-man.png',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Carte de profil principal
              Container(
                width: double.infinity,
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
                  children: [
                    // Avatar et infos de base
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
                          child: Center(
                            child: Text(
                              user.avatar,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Nom et niveau
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pureWhite,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Niveau ${user.currentLevel} - Salutations',
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

                    // Statistiques en ligne
                    Row(
                      children: [
                        // XP Total
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                user.totalXP.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pureWhite,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Text(
                                'XP Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pureWhite.withOpacity(0.8),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Série de jours
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${user.streakDays}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pureWhite,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              Text(
                                'jours de série',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pureWhite.withOpacity(0.8),
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progrès circulaire
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 6.0,
                          animation: true,
                          percent: progress.dailyProgress,
                          center: Text(
                            '${(progress.dailyProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: AppColors.pureWhite,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: AppColors.pureWhite,
                          backgroundColor: AppColors.pureWhite.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section Badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Badges obtenus',
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
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentOrange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accentOrange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              badge,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primaryBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Barre de progression de la leçon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progression de la leçon',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Leçon ${progress.currentLessonIndex} sur ${progress.totalLessons}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.primaryBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${((progress.currentLessonIndex / progress.totalLessons) * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress.currentLessonIndex /
                              progress.totalLessons,
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
              ),

              const SizedBox(height: 32),

              // Historique des leçons (simulé)
              Column(
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
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final lessons = [
                        'Leçon 8 - Salutations',
                        'Leçon 7 - Nombres',
                        'Leçon 6 - Couleurs',
                      ];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: AppColors.accentOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lessons[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.primaryBlack,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Complétée avec succès',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.successGreen,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.successGreen,
                              size: 24,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
