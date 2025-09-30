import 'package:flutter/material.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/lessons/services/lesson_service.dart';

class LessonScreen extends StatefulWidget {
  final String levelId;
  final String lessonId;
  
  const LessonScreen({
    super.key,
    required this.levelId,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Future<Lesson> _lessonFuture;
  final int _currentStep = 0;
  bool _isCompleted = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadLesson();
  }
  
  Future<void> _loadLesson() async {
    try {
      setState(() => _isLoading = true);
      final lesson = await LessonService.getLessonById(widget.lessonId);
      if (lesson != null) {
        _lessonFuture = Future.value(lesson);
      } else {
        // Gérer le cas où la leçon n'est pas trouvée
        throw Exception('Leçon non trouvée');
      }
    } catch (e) {
      // Gérer l'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement de la leçon: $e')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _completeLesson() async {
    try {
      // Utiliser le UserLessonService pour marquer la leçon comme terminée
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous devez être connecté pour compléter une leçon')),
          );
        }
        return;
      }
      
      await UserLessonService.completeLesson(
        userId: userId,
        lessonId: widget.lessonId,
      );
      
      setState(() => _isCompleted = true);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Félicitations! 🎉'),
            content: const Text('Vous avez terminé cette leçon avec succès!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Lesson>(
              future: _lessonFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('Aucune donnée de leçon disponible'));
                }

                final lesson = snapshot.data!;

                return Stack(
                  children: [
                    // Contenu principal
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 16.0,
                        bottom: 100.0, // Espace pour le bouton flottant
                      ),
                      child: CustomScrollView(
                        slivers: [
                          // En-tête avec la barre de progression
                          SliverToBoxAdapter(
                            child: _buildProgressBarAndHeader(context),
                          ),
                          
                          // Contenu de la leçon
                          SliverToBoxAdapter(
                            child: _buildLessonContent(lesson),
                          ),
                        ],
                      ),
                    ),

                    // Bouton d'action flottant
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 32,
                      child: _buildActionButton(),
                    ),
                  ],
                );
              },
            ),
    );
  }
  
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isCompleted ? null : _completeLesson,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCompleted
              ? AppColors.textSecondary.withOpacity(0.5)
              : AppColors.accentOrange,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child: Text(
          _isCompleted ? 'Terminé' : 'Marquer comme terminé',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBarAndHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton de retour
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryBlack,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        
        const SizedBox(height: 16),
        
        // Barre de progression
        LinearPercentIndicator(
          lineHeight: 6.0,
          percent: 1.0, // Vous pouvez adapter cela en fonction de la progression
          backgroundColor: AppColors.secondaryBeige,
          progressColor: AppColors.accentOrange,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLessonContent(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la leçon
        Text(
          lesson.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w700,
              ),
        ),
        
        const SizedBox(height: 24),
        
        // Contenu de la leçon
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            lesson.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Section d'exemples (optionnelle)
        // Vous pouvez ajouter une section pour les exemples si nécessaire
        // _buildExamplesSection(),
      ],
    );
  }

  // Méthode pour construire une section d'exemples (optionnelle)
  // Widget _buildExamplesSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Exemples',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //               color: AppColors.primaryBlack,
  //               fontWeight: FontWeight.w600,
  //             ),
  //       ),
  //       const SizedBox(height: 16),
  //       // Ajoutez vos exemples ici
  //     ],
  //   );
  // }
}
