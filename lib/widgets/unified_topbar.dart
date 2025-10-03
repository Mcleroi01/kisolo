import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/profiles/services/profile_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

/// TopBar unifié pour toute l'application
/// À utiliser dans toutes les pages pour une cohérence visuelle
class UnifiedTopBar extends StatefulWidget {
  final bool showProgress;
  final double? customProgress;
  final VoidCallback? onProfileTap;

  const UnifiedTopBar({
    super.key,
    this.showProgress = true,
    this.customProgress,
    this.onProfileTap,
  });

  @override
  State<UnifiedTopBar> createState() => _UnifiedTopBarState();
}

class _UnifiedTopBarState extends State<UnifiedTopBar> {
  int _streakDays = 0;
  double _globalProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final profile = await ProfileService.getCurrentUserProfile();
      
      // Simuler progression globale basée sur les points
      final progress = (profile.points / 1000).clamp(0.0, 1.0);
      
      if (mounted) {
        setState(() {
          _streakDays = 14; // À remplacer par la vraie valeur depuis la DB
          _globalProgress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Erreur chargement stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _globalProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayProgress = widget.customProgress ?? _globalProgress;
    final currentUser = AuthService.currentUser;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryBeige,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar de Profil
          GestureDetector(
            onTap: widget.onProfileTap ?? () => context.push('/profile'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.accentOrange, width: 2),
              ),
              child: currentUser?.userMetadata?['avatar_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        currentUser!.userMetadata!['avatar_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.accentOrange,
                          size: 30,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.accentOrange,
                      size: 30,
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Barre de progression globale
          if (widget.showProgress)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texte de progression
                  Text(
                    _isLoading ? 'Chargement...' : 'Progression globale',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Barre de progression
                  _isLoading
                      ? Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBeige.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: displayProgress.clamp(0.0, 1.0),
                          backgroundColor:
                              AppColors.secondaryBeige.withOpacity(0.5),
                          progressColor: AppColors.accentOrange,
                          barRadius: const Radius.circular(10),
                          padding: EdgeInsets.zero,
                        ),
                ],
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 16),

          // Jours de Série (Streak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Text(
                  _isLoading ? '...' : '$_streakDays',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}