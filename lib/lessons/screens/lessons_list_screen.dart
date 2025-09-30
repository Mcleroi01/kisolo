import 'package:flutter/material.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/lessons/services/lesson_service.dart';
import 'package:kisolo/levels/models/level.dart';
import 'package:kisolo/levels/services/level_service.dart';
import 'package:kisolo/lessons/screens/lesson_screen.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LessonsListScreen extends StatefulWidget {
  const LessonsListScreen({super.key});

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  late Future<List<Level>> _levelsFuture;
  final Map<String, List<Lesson>> _lessonsByLevel = {};
  final Map<String, double> _levelProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load all levels
      final levels = await LevelService.getLevels();
      
      // Load lessons for each level
      for (var level in levels) {
        final lessons = await LessonService.getLessonsByLevel(level.id);
        _lessonsByLevel[level.id] = lessons;
        
        // Calculate progress for each level
        final progress = await _calculateLevelProgress(level.id, lessons);
        _levelProgress[level.id] = progress;
      }
      
      setState(() {
        _levelsFuture = Future.value(levels);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des leçons: $e')),
        );
      }
    }
  }

  Future<double> _calculateLevelProgress(String levelId, List<Lesson> lessons) async {
    if (lessons.isEmpty) return 0.0;
    
    int completedLessons = 0;
    const userId = 'current_user_id'; // Replace with actual user ID
    
    for (var lesson in lessons) {
      final isCompleted = await UserLessonService.isLessonCompleted(
        userId: userId,
        lessonId: lesson.id,
      );
      if (isCompleted) completedLessons++;
    }
    
    return completedLessons / lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apprendre le Portugais', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Level>>(
              future: _levelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                
                final levels = snapshot.data ?? [];
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final lessons = _lessonsByLevel[level.id] ?? [];
                    final progress = _levelProgress[level.id] ?? 0.0;
                    
                    return _buildLevelCard(level, lessons, progress, context);
                  },
                );
              },
            ),
    );
  }

  Widget _buildLevelCard(Level level, List<Lesson> lessons, double progress, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showLevelDetails(level, lessons, context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  _buildProgressChip(progress),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                level.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: progress,
                backgroundColor: Colors.grey[200],
                progressColor: _getProgressColor(progress),
                barRadius: const Radius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% complété',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _buildLessonChips(lessons),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChip(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getProgressColor(progress).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: _getProgressColor(progress),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLessonChips(List<Lesson> lessons) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lessons.map((lesson) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonScreen(
                  levelId: lesson.levelId,
                  lessonId: lesson.id,
                ),
              ),
            );
          },
          child: Chip(
            label: Text(
              'Leçon ${lesson.order}',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _showLevelDetails(Level level, List<Lesson> lessons, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              level.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
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
            const SizedBox(height: 16),
            const Text(
              'Leçons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlack,
                      child: Text(
                        '${lesson.order}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(lesson.title),
                    subtitle: Text(
                      '${(lesson.content.length / 200).ceil()} min',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
