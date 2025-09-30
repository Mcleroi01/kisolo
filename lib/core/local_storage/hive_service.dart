import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisolo/lessons/model/lesson.dart';

// Run this command in terminal to generate adapters:
// flutter pub run build_runner build --delete-conflicting-outputs

class HiveService {
  static const String _lessonsBox = 'lessons_box';
  static const String _userLevelKey = 'user_level';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LessonAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Lesson>(_lessonsBox);
    await Hive.openBox(_userLevelKey);
  }

  static Box<Lesson> get _lessonsBoxInstance => Hive.box<Lesson>(_lessonsBox);
  static Box get _userLevelBox => Hive.box(_userLevelKey);

  // Save user's current level
  static Future<void> saveUserLevel(String levelId) async {
    await _userLevelBox.put('current_level', levelId);
  }

  // Get user's current level
  static String? getUserLevel() {
    return _userLevelBox.get('current_level');
  }

  // Save lessons for a specific level
  static Future<void> saveLessonsForLevel(String levelId, List<Lesson> lessons) async {
    // Clear existing lessons for this level
    final existingKeys = _lessonsBoxInstance.keys.where(
      (key) => key.toString().startsWith('${levelId}_')
    ).toList();
    
    await _lessonsBoxInstance.deleteAll(existingKeys);
    
    // Save new lessons
    for (var lesson in lessons) {
      await _lessonsBoxInstance.put('${levelId}_${lesson.id}', lesson);
    }
  }

  // Get all lessons for a specific level from local storage
  static List<Lesson> getLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values
        .where((lesson) => lesson.levelId == levelId)
        .toList();
  }

  // Check if we have lessons for a specific level in local storage
  static bool hasLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values.any((lesson) => lesson.levelId == levelId);
  }

  // Clear all local data (for testing or logout)
  static Future<void> clearAll() async {
    await _lessonsBoxInstance.clear();
    await _userLevelBox.clear();
  }
}
