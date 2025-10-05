import 'package:flutter/material.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/lessons/services/lesson_service.dart';
import 'package:kisolo/levels/models/level.dart';
import 'package:kisolo/levels/services/level_service.dart';
import 'package:kisolo/lessons/screens/lesson_screen.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:kisolo/widgets/unified_topbar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';



// Définition de l'écran des listes de leçons
class LessonsListScreen extends StatefulWidget {
  const LessonsListScreen({super.key});

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  Future<List<Level>>? _levelsFuture;
  final Map<String, List<Lesson>> _lessonsByLevel = {};
  final Map<String, double> _levelProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOGIQUE MÉTIER (conservée) ---

  Future<void> _loadData() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final levels = await LevelService.getLevels();
      final userId = AuthService.currentUser?.id;

      for (var level in levels) {
        final lessons = await LessonService.getLessonsByLevel(level.id);
        _lessonsByLevel[level.id] = lessons;

        if (userId != null) {
          final progress = await _calculateLevelProgress(userId, level.id, lessons);
          _levelProgress[level.id] = progress;
        } else {
          _levelProgress[level.id] = 0.0;
        }
      }

      if (mounted) {
        setState(() {
          _levelsFuture = Future.value(levels);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement leçons: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des leçons: ${e.toString().split(':')[0]}')),
        );
      }
    }
  }

  Future<double> _calculateLevelProgress(
      String userId, String levelId, List<Lesson> lessons) async {
    if (lessons.isEmpty) return 0.0;
    try {
      int completedLessons = 0;
      for (var lesson in lessons) {
        final isCompleted = await UserLessonService.isLessonCompleted(
          userId: userId,
          lessonId: lesson.id,
        );
        if (isCompleted) completedLessons++;
      }
      return completedLessons / lessons.length;
    } catch (e) {
      debugPrint('⚠️ Erreur calcul progression: $e');
      return 0.0;
    }
  }

  // --- DESIGN: MAPPING Icône et Couleur Thématique ---
  
  IconData _getLevelIcon(String levelTitle) {
    if (levelTitle.toLowerCase().contains('bokutani')) return Icons.rocket_launch_rounded;
    if (levelTitle.toLowerCase().contains('mosali ya bolukiluki')) return Icons.map_rounded;
    if (levelTitle.toLowerCase().contains('maîtrise na yango')) return Icons.star_rounded;
    return Icons.school_rounded;
  }
  
  Color _getLevelColor(String levelTitle) {
    if (levelTitle.toLowerCase().contains('bokutani')) return Colors.teal.shade500;
    if (levelTitle.toLowerCase().contains('mosali ya bolukiluki')) return AppColors.accentOrange;
    if (levelTitle.toLowerCase().contains('maîtrise na yango')) return Colors.deepPurple.shade500;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utilisation d'une couleur de fond légèrement différente du blanc pur pour un effet moderne
      backgroundColor: AppColors.secondaryBeige, 
      body: _buildBody(),
    );
  }

  // -------------------------------------------------------------------
  // ## NOUVEAU WIDGET: AppBar Moderne (aligné sur l'UX de la page d'accueil)
  // -------------------------------------------------------------------
 

  // -------------------------------------------------------------------
  // ## Corps de la Page (Gestion des états)
  // -------------------------------------------------------------------
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
     
            CircularProgressIndicator(color: AppColors.accentOrange),
            SizedBox(height: 16),
            Text('Chargement des leçons...', style: TextStyle(color: AppColors.primaryBlack)),
          ],
        ),
      );
    }

    return FutureBuilder<List<Level>>(
      future: _levelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          // Gérer l'état d'erreur
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                 const SizedBox(height: 16),
                 Text('Erreur: ${snapshot.error.toString().split(':')[0]}'),
                 const SizedBox(height: 16),
                 ElevatedButton(
                   onPressed: _loadData,
                   style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: AppColors.pureWhite,
                   ),
                   child: const Text('Réessayer'),
                 ),
               ],
             ),
           );
        }

        final levels = snapshot.data ?? [];

        if (levels.isEmpty) {
          return const Center(child: Text('Aucune leçon disponible'));
        }

        // Liste des cartes de niveaux
        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.accentOrange,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), 
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              final lessons = _lessonsByLevel[level.id] ?? [];
              final progress = _levelProgress[level.id] ?? 0.0;

              return _buildLevelCardModern(level, lessons, progress, context);
            },
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET AMÉLIORÉ: Carte de Niveau (Design Moderne)
  // -------------------------------------------------------------------
  Widget _buildLevelCardModern(Level level, List<Lesson> lessons, double progress,
      BuildContext context) {
    final levelColor = _getLevelColor(level.title);
    final isCompleted = progress >= 0.999; // Utiliser une tolérance pour le float

    return Container(
      margin: const EdgeInsets.only(bottom: 24), // Espacement plus grand
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          // Ombre colorée et prononcée (comme sur la page d'accueil)
          BoxShadow(
            color: levelColor.withOpacity(0.2), 
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: isCompleted
            ? Border.all(color: Colors.green.shade500, width: 3)
            : Border.all(color: Colors.grey.shade100, width: 1), // Bordure légère non complétée
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showLevelDetails(level, lessons, context, levelColor),
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Padding généreux
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ligne supérieure: Icône et Titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      _getLevelIcon(level.title),
                      size: 36,
                      color: levelColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        level.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    // Indication de l'état (Complété ou pourcentage)
                    _buildStatusBadge(progress, isCompleted, levelColor),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 2. Description
                Text(
                  level.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // 3. Barre de Progression
                Row(
                  children: [
                    Expanded(
                      child: LinearPercentIndicator(
                        lineHeight: 12.0, // Barre plus épaisse
                        percent: progress,
                        backgroundColor: AppColors.secondaryBeige, // Fond beige doux
                        progressColor: isCompleted ? Colors.green : levelColor,
                        barRadius: const Radius.circular(6),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isCompleted ? Colors.green : levelColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET AMÉLIORÉ: Badge de Statut
  // -------------------------------------------------------------------
  Widget _buildStatusBadge(double progress, bool isCompleted, Color levelColor) {
    if (isCompleted) {
      // Utilisez un Chip pour un look professionnel et complété
      return Chip(
        avatar: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
        label: const Text('Complété', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        backgroundColor: Colors.green.shade500,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      );
    }
    // Sinon, affichez un badge de progression
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: levelColor,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET AMÉLIORÉ: Modal Bottom Sheet (Détails)
  // -------------------------------------------------------------------
  void _showLevelDetails(
      Level level, List<Lesson> lessons, BuildContext context, Color levelColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        decoration: const BoxDecoration(
          color: AppColors.pureWhite, // Fond blanc pur pour les détails
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)), 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle de tirage
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            
            // Entête du Modal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: levelColor, // Utiliser la couleur thématique pour le titre
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Curriculum (${lessons.length} leçons)',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack, 
                    ),
                  ),
                  const Divider(height: 20, color: Colors.grey),
                ],
              ),
            ),
            
            // Liste des Leçons
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final estimatedTime = (lesson.order * 2 + 3); 
                  
                  return _buildLessonTile(lesson, level, estimatedTime, levelColor, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // -------------------------------------------------------------------
  // ## NOUVEAU WIDGET: Tuile de Leçon détaillée
  // -------------------------------------------------------------------
  Widget _buildLessonTile(
      Lesson lesson, Level level, int estimatedTime, Color levelColor, BuildContext context) {
    // Simuler le statut de déverrouillage pour une meilleure UX
    final isUnlocked = lesson.order <= 3; // Par exemple, les 3 premières leçons sont déverrouillées

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: isUnlocked 
            ? levelColor.withOpacity(0.15) 
            : Colors.grey.shade200,
        child: Icon(
          isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
          color: isUnlocked ? levelColor : Colors.grey,
          size: 24,
        ),
      ),
      title: Text(
        lesson.phrasePt.split(',')[0], 
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isUnlocked ? AppColors.primaryBlack : Colors.grey,
        ),
      ),
      subtitle: Text(
        'Leçon ${lesson.order} - $estimatedTime min',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: isUnlocked 
        ? Icon(Icons.arrow_forward_ios_rounded, size: 18, color: levelColor)
        : const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
      onTap: isUnlocked ? () {
        Navigator.pop(context); 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonScreen(
              levelId: level.id,
              lessonId: lesson.id,
            ),
          ),
        );
      } : null, // Ne rien faire si la leçon est verrouillée
    );
  }
}