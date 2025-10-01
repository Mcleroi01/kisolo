import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:kisolo/lessons/services/lesson_service.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// --- NOUVEAU: Enumération simple pour les étapes de la leçon (simulées) ---
// La dernière étape 'complete' est l'écran final, pas une étape de contenu.
enum LessonStep {
  portuguesePhrase,
  lingalaTranslation,
  notesExplanation,
  complete
}

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
  // --- Changements d'état pour la progression dans la leçon ---
  Future<Lesson>? _lessonFuture;
  LessonStep _currentStep =
      LessonStep.portuguesePhrase; // Commence par la phrase PT
  bool _isLessonCompleted = false; // Statut de la leçon dans la DB
  bool _isLoading = true;
  bool _isSpeaking = false; // État du TTS

  // --- NOUVEAU: Contrôleur TTS ---
  late FlutterTts _flutterTts;

  // Le nombre total d'étapes de contenu est la taille de l'énumération moins l'état 'complete'.
  final int _totalContentSteps = LessonStep.values.length - 1;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadLesson();
  }

  // --- Initialisation du TTS (conservée) ---
  void _initializeTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('pt-BR'); // Langue portugaise du Brésil
    _flutterTts
        .setSpeechRate(0.8); // Vitesse légèrement ralentie pour l'apprentissage
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
      debugPrint('Erreur TTS: $msg');
    });
  }

  // --- Méthode pour jouer l'audio TTS (conservée) ---
  Future<void> _speakPortuguesePhrase(String text) async {
    // Si déjà en train de parler, arrêter avant de recommencer
    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
      return;
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Erreur lors de la lecture TTS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la lecture audio: ${e.toString().split(':')[0]}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Chargement de la leçon (conservé) ---
  Future<void> _loadLesson() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final lesson = await LessonService.getLessonById(widget.lessonId);

      if (lesson != null) {
        final userId = AuthService.currentUser?.id;
        if (userId != null) {
          _isLessonCompleted = await UserLessonService.isLessonCompleted(
            userId: userId,
            lessonId: widget.lessonId,
          );
        }

        _lessonFuture = Future.value(lesson);
        // Si la leçon est déjà complétée, aller à l'écran de fin
        if (_isLessonCompleted) {
          _currentStep = LessonStep.complete;
        }
      } else {
        throw Exception('Liteya ezwami te');
      }
    } catch (e) {
      debugPrint('❌ Libunga na chargement ya liteya: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Libunga na chargement ya liteya: ${e.toString().split(':')[0]}')),
        );
        // Ne pas pop si on est en dev, mais c'est une bonne pratique en prod
        // Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- LOGIQUE: Avancer à l'étape suivante ---
  void _nextStep() {
    final currentStepIndex = _currentStep.index;

    // Si le TTS est actif, l'arrêter avant de passer à l'étape suivante
    if (_isSpeaking) {
      _flutterTts.stop();
    }

    if (currentStepIndex < _totalContentSteps - 1) {
      // Avancer à la prochaine étape de contenu
      setState(() {
        _currentStep = LessonStep.values[currentStepIndex + 1];
      });
    } else if (_currentStep == LessonStep.notesExplanation) {
      // Dernière étape de contenu -> Compléter la leçon
      _completeLesson();
    }
  }

  // --- LOGIQUE: Compléter la leçon ---
  void _completeLesson() async {
    try {
      final userId = AuthService.currentUser?.id;
      // Vérifier si l'utilisateur est connecté et si la leçon n'est PAS déjà complétée
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Veuillez vous connecter pour valider la leçon.')),
          );
        }
        return;
      }

      // La ligne ci-dessous empêche de marquer une leçon déjà complétée (sauf si l'état local est faux)
      if (_isLessonCompleted) {
        setState(() => _currentStep = LessonStep.complete);
        return;
      }

      await UserLessonService.completeLesson(
        userId: userId,
        lessonId: widget.lessonId,
      );

      if (mounted) {
        setState(() {
          _isLessonCompleted = true;
          _currentStep = LessonStep.complete;
        });

        // Afficher la boîte de dialogue de victoire/succès
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Libunga na tango ya validation: ${e.toString().split(':')[0]}')),
        );
      }
    }
  }

  // --- DIALOGUE: Afficher le dialogue de succès (amélioré) ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.pureWhite,
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 30),
            SizedBox(width: 10),
            Text('Félicitations ! 🎉',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack)),
          ],
        ),
        content: const Text(
          'Osilisi liteya oyo malamu mpe osali bokoli na boyekoli na yo ya Portugais !',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) =>
                  route.isFirst); // Retourner à la page principale (ou liste)
            },
            child: const Text(
              'Zongela Mateya',
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

  // -------------------------------------------------------------------
  // ## Structure de la Page
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange))
          : FutureBuilder<Lesson>(
              future: _lessonFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('Ba données ya mateya ezali te'));
                }

                final lesson = snapshot.data!;

                return Stack(
                  children: [
                    // Contenu principal avec padding adapté
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            _buildProgressBarAndHeader(context),
                            Expanded(
                              // Le contenu est géré par l'état LessonStep
                              child: _buildLessonContent(lesson),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton d'action flottant au bas de l'écran
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

  // -------------------------------------------------------------------
  // ## WIDGET: Barre de Progression et Entête
  // -------------------------------------------------------------------
  Widget _buildProgressBarAndHeader(BuildContext context) {
    // Calcul de la progression actuelle (basé sur le total d'étapes de contenu)
    final progress = (_currentStep.index + 1) / _totalContentSteps;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
      child: Row(
        children: [
          // Bouton de retour (Utilisation de l'icône "fermer" pour un flux d'apprentissage)
          InkWell(
            onTap: () {
              _flutterTts.stop();
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close_rounded, // Icône de fermeture
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Barre de progression
          Expanded(
            child: LinearPercentIndicator(
              lineHeight: 12.0,
              percent: progress > 1.0 ? 1.0 : progress,
              backgroundColor: AppColors.secondaryBeige.withOpacity(0.5),
              progressColor: _currentStep == LessonStep.complete
                  ? Colors.green
                  : AppColors.accentOrange,
              barRadius: const Radius.circular(10),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET: Contenu Dynamique de la Leçon
  // -------------------------------------------------------------------
  Widget _buildLessonContent(Lesson lesson) {
    String title = '';
    String subtitle = '';
    IconData icon;
    Color color;

    // Déterminer le contenu en fonction de l'étape actuelle
    switch (_currentStep) {
      case LessonStep.portuguesePhrase:
        title = 'Yoka pe Zongela (Portugais 🇵🇹)';
        subtitle = lesson.phrasePt;
        icon = Icons.volume_up_rounded;
        color = AppColors.accentOrange;
        break;

      case LessonStep.lingalaTranslation:
        title = 'Bobongoli (Lingala 🇨🇩)';
        subtitle = lesson.phraseLn;
        icon = Icons.translate_rounded;
        color = Colors.blue.shade600;
        break;

      case LessonStep.notesExplanation:
        title = 'Banote ya koteya💡';
        subtitle =
            lesson.notes ?? 'Banote ya sikisiki epesami te mpo na liteya oyo.';
        icon = Icons.info_outline_rounded;
        color = Colors.teal.shade600;
        break;

      case LessonStep.complete:
        return _buildCompletionState(); // Widget de fin (séparé)
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Carte principale du contenu (Design moderne et thématique)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize:
                        _currentStep == LessonStep.portuguesePhrase ? 36 : 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlack,
                    height: 1.4,
                  ),
                ),
                // --- Bouton Audio pour la phrase portugaise ---
                if (_currentStep == LessonStep.portuguesePhrase) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _isSpeaking ? 'Arrêtez l\'audio...' : 'Écoutez',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isSpeaking ? Colors.grey : color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bouton circulaire pour le TTS
                      Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () =>
                              _speakPortuguesePhrase(lesson.phrasePt),
                          icon: Icon(
                            _isSpeaking
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            size: 30,
                            color: AppColors.pureWhite,
                          ),
                          tooltip: _isSpeaking
                              ? 'Arrêter'
                              : 'Écouter la prononciation',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(
              height: 120), // Espace pour le bouton d'action flottant
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET: Barre d'Action Flottante
  // -------------------------------------------------------------------
  Widget _buildActionButton() {
    final bool isFinished =
        _currentStep == LessonStep.complete || _isLessonCompleted;
    String buttonText;

    if (isFinished) {
      buttonText = 'Zongela Mateya (Retour)';
    } else if (_currentStep == LessonStep.notesExplanation) {
      buttonText = 'Silisa Liteya';
    } else {
      buttonText = 'Koba';
    }

    return SizedBox(
      width: double.infinity,
      height: 60, // Bouton plus grand
      child: ElevatedButton(
        onPressed: isFinished
            ? () {
                // Si terminé, retourner à la page précédente.
                Navigator.pop(context);
              }
            : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFinished ? Colors.green.shade500 : AppColors.accentOrange,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6, // Plus d'ombre
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET: État de Complétion
  // -------------------------------------------------------------------
  Widget _buildCompletionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 150.0), // Espace du bouton
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 120, color: Colors.green),
            const SizedBox(height: 32),
            Text(
              'Liteya ${widget.lessonId.substring(0, 4)} Esili!',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Mosala ya malamu mpenza. Bokoli na yo esili kokomama.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
