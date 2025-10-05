import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/user_progress/models/user_lesson.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/profiles/models/profile.dart';
import 'package:kisolo/profiles/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  int? _completedLessonsCount;

  Profile? get profile => _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current user profile
      final profile = await ProfileService.getCurrentUserProfile();
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        await ProfileService.updateStats(currentUser.id);

        // Fetch updated profile with new statistics
        final updatedProfile = await ProfileService.getCurrentUserProfile();

        // Load additional lesson data
        final completedLessonsCount = await UserLessonService.getCompletedLessonsCount(currentUser.id);

        if (mounted) {
          setState(() {
            _userProfile = updatedProfile;
            _completedLessonsCount = completedLessonsCount;
            _isLoading = false;
          });
        }
      } else {
        // Load lesson data even for non-authenticated users (if needed)
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement profil: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content:
            const Text('Olingi vraiment kobima na Kisolo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Déconnecter',
                style: TextStyle(color: AppColors.pureWhite)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await AuthService.signOut();

      if (success && mounted) {
        context.go('/onboarding');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la déconnexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      // Écran d'état non connecté
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle,
                  size: 80, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text('Non connecté.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/onboarding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.pureWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Se connecter ou s\'inscrire'),
              ),
            ],
          ),
        ),
      );
    }

    // Affichage principal
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange))
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  color: AppColors.accentOrange,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     
                        FutureBuilder<Widget>(
                          future: _buildHeader(context, _userProfile!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top + 20,
                                  left: 24,
                                  right: 24,
                                  bottom: 24,
                                ),
                                color: AppColors.pureWhite,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top + 20,
                                  left: 24,
                                  right: 24,
                                  bottom: 24,
                                ),
                                color: AppColors.pureWhite,
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top + 20,
                                  left: 24,
                                  right: 24,
                                  bottom: 24,
                                ),
                                color: AppColors.pureWhite,
                                child: const Center(
                                  child: Text('Erreur lors du chargement'),
                                ),
                              );
                            }
                          },
                        ),
                        // Section des Statistiques Clés
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _buildStatsSection(_userProfile!),
                        ),

                        const SizedBox(height: 32),

                        // Section des Badges (Jalons)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _buildBadgesSection(),
                        ),

                        const SizedBox(height: 32),

                        // Section Paramètres/Déconnexion
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _buildSettingsSection(),
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGETS DE COMPOSANT
  // -------------------------------------------------------------------

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserProfile,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 1: En-tête (Style Duolingo) ---
  Future<Widget> _buildHeader(BuildContext context, Profile profile) async {
    final currentUser = AuthService.currentUser;
    final displayName = currentUser?.userMetadata?['full_name'] as String? ??
        currentUser?.userMetadata?['name'] as String? ??
        profile.name;

    final completedLessonsCount =
        await UserLessonService.getCompletedLessonsCount(profile.id);

    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              20, // Espace pour la barre d'état
          left: 24,
          right: 24,
          bottom: 24),
      color: AppColors.pureWhite,
      child: Column(
        children: [
          // Row pour l'action (Déconnexion/Paramètres)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // Logique pour ouvrir les paramètres (à implémenter)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Ouverture des Paramètres...')));
                },
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary, size: 28),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout,
                    color: AppColors.textSecondary, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Avatar central
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.accentOrange, width: 3),
            ),
            child: Center(
              // Utiliser une grande icône comme avatar par défaut
              child: Text(
                _getAvatarEmoji(profile.gender),
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nom de l'utilisateur
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlack,
                  fontFamily: 'Nunito',
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Niveaux et progression (simplifié)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryBeige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Nivo ${completedLessonsCount ~/ 10 + 1}', // Niveau basé sur les leçons
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 2: Section des Statistiques Clés (Duolingo style) ---
  Widget _buildStatsSection(Profile profile) {
    final completedLessonsCount = _completedLessonsCount ?? profile.lessonsCompleted;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(top: 20,bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
              value: '${profile.streakDays}',
              label: 'Milongo',
              icon: Icons.local_fire_department_rounded,
              color: Colors.orange,
            ),
            _buildVerticalDivider(),
            _buildStatColumn(
              value: '${profile.points}',
              label: 'Total ya XP',
              icon: Icons.star_rounded,
              color: AppColors.accentOrange,
            ),
            _buildVerticalDivider(),
            _buildStatColumn(
              value: '$completedLessonsCount',
              label: 'Mateya',
              icon: Icons.school_rounded,
              color: AppColors.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGET 3: Section des Badges (Jalons) ---
  Widget _buildBadgesSection() {
    final badges = _getUserBadges();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Makambo ya ntina mpe malonga',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110, // Hauteur fixe pour le défilement horizontal
          child: badges.isEmpty
              ? const Center(
                  child: Text(
                    'Ba badge moko te efungolami naino',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _buildBadgeItem(badge);
                  },
                ),
        ),
      ],
    );
  }

  // Générer les badges basés sur les réalisations de l'utilisateur
  List<Map<String, dynamic>> _getUserBadges() {
    final badges = <Map<String, dynamic>>[];
    final profile = _userProfile;
    final int? lessoncompleted = _completedLessonsCount ;

    if (profile == null) return badges;

    // Badge pour les leçons complétées
    if (profile.lessonsCompleted >= 1) {
      badges.add({
        'icon': Icons.school_rounded,
        'color': AppColors.successGreen,
        'label': '${lessoncompleted} Leçons',
        'desc': '${lessoncompleted} leçons complétées',
      });
    }

    // Badge pour la série
    if (profile.streakDays >= 1) {
      badges.add({
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange,
        'label': '${profile.streakDays} Jours',
        'desc': 'Série de ${profile.streakDays} jours',
      });
    }

    // Badge pour les points
    if (profile.points >= 100) {
      badges.add({
        'icon': Icons.star_rounded,
        'color': AppColors.accentOrange,
        'label': '${profile.points} XP',
        'desc': '${profile.points} points gagnés',
      });
    }

    // Badge de bienvenue (toujours présent)
    badges.add({
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xFFE55D3A),
      'label': 'Bienvenue',
      'desc': 'Bienvenue sur Kisolo !',
    });

    return badges;
  }

  // --- WIDGET 4: Section Paramètres/Déconnexion ---
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compte mpe Lisungi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.edit_note_rounded,
                label: 'Bobongisi Profil',
                onTap: _editProfile,
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildSettingTile(
                icon: Icons.help_outline_rounded,
                label: 'Lisalisi mpe Lisungi',
                onTap: () {/* Naviguer vers l'aide */},
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildSettingTile(
                icon: Icons.logout_rounded,
                label: 'Kokata boyokani',
                color: Colors.red,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // ## WIDGETS UTILITAIRES
  // -------------------------------------------------------------------

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.accentOrange,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentOrange, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(badge['icon'] as IconData,
              size: 36, color: badge['color'] as Color),
          const SizedBox(height: 8),
          Text(
            badge['label'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primaryBlack,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Future<void> _editProfile() async {
    // TODO: Navigate to profile editing screen
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Fonctionnalité d\'édition de profil à venir...')));
  }

  String _getAvatarEmoji(Gender gender) {
    switch (gender) {
      case Gender.male:
        return '🧑🏾';
      case Gender.female:
        return '👩🏽';
      case Gender.other:
        return '👽';
    }
  }
}
