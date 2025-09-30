import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisolo/lessons/model/lesson.dart';

class LocalStorageService {
  // Authentication related
  static const String _authBox = 'auth_box';
  static const String _userProfileKey = 'user_profile';
  static const String _authTokenKey = 'auth_token';
  
  // Lessons related
  static const String _lessonsBox = 'lessons_box';
  static const String _userLevelKey = 'user_level';

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LessonAdapter());
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
  
  static List<Lesson> getLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values
        .where((lesson) => lesson.levelId == levelId)
        .toList();
  }
  
  static bool hasLessonsForLevel(String levelId) {
    return _lessonsBoxInstance.values.any((lesson) => lesson.levelId == levelId);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Future.wait([
      _box.clear(),
      _lessonsBoxInstance.clear(),
      _userLevelBox.clear(),
    ]);
  }
}
