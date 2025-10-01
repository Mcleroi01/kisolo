import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/levels/models/level.dart';

class LocalStorageService {
  // Authentication related
  static const String _authBox = 'auth_box';
  static const String _userProfileKey = 'user_profile';
  static const String _authTokenKey = 'auth_token';

  // Lessons related
  static const String _lessonsBox = 'lessons_box';
  static const String _userLevelKey = 'user_level';
  static const String _level = 'levels';

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LessonAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LevelAdapter());
    }

    // Open all boxes
    await Future.wait([
      Hive.openBox(_authBox),
      Hive.openBox<Lesson>(_lessonsBox),
      Hive.openBox(_userLevelKey),
    ]);
  }

  // Get boxes
  static Box get _box => Hive.box(_authBox);
  static Box<Lesson> get _lessonsBoxInstance => Hive.box<Lesson>(_lessonsBox);
  static Box get _userLevelBox => Hive.box(_userLevelKey);

  // User Profile
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _box.put(_userProfileKey, profile);
  }

  static Map<String, dynamic>? getUserProfile() {
    return _box.get(_userProfileKey);
  }

  // Auth Token
  static Future<void> saveAuthToken(String token) async {
    await _box.put(_authTokenKey, token);
  }

  static String? getAuthToken() {
    return _box.get(_authTokenKey);
  }

  // User Level
  static Future<void> saveUserLevel(String levelId) async {
    await _userLevelBox.put('current_level', levelId);
  }

  static String? getUserLevel() {
    return _userLevelBox.get('current_level');
  }

  // Lessons
  static Future<void> saveLessonsForLevel(
      String levelId, List<Lesson> lessons) async {
    // Clear existing lessons for this level
    final existingKeys = _lessonsBoxInstance.keys
        .where((key) => key.toString().startsWith('${levelId}_'))
        .toList();

    await _lessonsBoxInstance.deleteAll(existingKeys);

    // Save new lessons
    for (var lesson in lessons) {
      await _lessonsBoxInstance.put('${levelId}_${lesson.id}', lesson);
    }
  }

  static List<Lesson> getLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values
        .where((lesson) => lesson.levelId == levelId)
        .toList();
  }

  static bool hasLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values
        .any((lesson) => lesson.levelId == levelId);
  }

  static Future<void> saveLevels(List<Level> levels) async {
    await _box.put(_level, levels);
  }

  static List<Level> getLevel() {
    return _box.get(_level) ?? [];
  }

  static bool hasLevel() {
    return _box.get(_level) != null;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Future.wait([
      _box.clear(),
      _lessonsBoxInstance.clear(),
      _userLevelBox.clear(),
    ]);
    print('✅ All local storage cleared');
  }

  // Fonction utilitaire pour vider le local storage depuis l'application
  static Future<bool> clearLocalStorage() async {
    try {
      await clearAll();
      print('✅ Local storage vidé avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors du vidage du local storage: $e');
      return false;
    }
  }
}
