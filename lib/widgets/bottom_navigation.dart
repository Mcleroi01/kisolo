import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';
import 'package:kisolo/home/screens/home_screen.dart';
import 'package:kisolo/lessons/screens/lessons_list_screen.dart';
import 'package:kisolo/profiles/screen/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  // appBar est souvent géré par chaque écran individuel pour une meilleure flexibilité
  const BottomNavigation({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex;
  late PageController _pageController; // Pour gérer la transition d'écran

  // Liste des écrans (gardée en place)
  final List<Widget> _screens = const [
    HomeScreen(),
    LessonsListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Mettre à jour l'index et naviguer avec animation
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animation douce vers la nouvelle page (meilleure UX)
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Liste des éléments de navigation avec des icônes modernes
  List<BottomNavigationBarItem> get _navItems => [
        const BottomNavigationBarItem(
          // Icône normale
          icon: Icon(Icons.home_outlined),
          // Icône sélectionnée (remplie) pour un meilleur feedback
          activeIcon: Icon(Icons.home_rounded),
          label: 'Ndaku',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book_rounded),
          label: 'Mateya',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nous retirons l'AppBar de Scaffold.
      // Il est préférable de l'ajouter dans chaque écran (HomeScreen, etc.)
      // pour gérer les titres et actions spécifiques à chaque vue.
      body: PageView(
        controller: _pageController,
        // Empêche le défilement horizontal par geste
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          // Ceci permet de synchroniser la barre si on active le swipe
          // (Actuellement désactivé par NeverScrollableScrollPhysics)
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      // -------------------------------------------------------------------
      // ## BottomNavigationBar Améliorée
      // -------------------------------------------------------------------
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondaryBeige,
          // Remplacement de l'ombre par une bordure supérieure subtile
          border: Border(
            top: BorderSide(color: AppColors.primaryBlack, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped, // Utilisation de la nouvelle fonction de tap
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Nécessaire car le Container gère la couleur
          elevation: 0, // Retiré, géré par le Container
          
          // Couleurs et style
          selectedItemColor: AppColors.accentOrange,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700, // Plus gras
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
          
          // Rendre les icônes légèrement plus grandes pour l'UX
          iconSize: 26, 
          
          items: _navItems,
        ),
      ),
    );
  }
}

// **NOTE :** J'ai ajouté AppColors.dividerColor et AppColors.textSecondary 
// dans le code ci-dessus, en supposant qu'ils existent dans votre fichier
// `kisolo/core/utils/app_colors.dart`.
// Si ce n'est pas le cas, vous pouvez les définir comme ceci dans ce fichier :
// abstract class AppColors {
//   static const Color accentOrange = Color(0xFFFB8500);
//   static const Color pureWhite = Colors.white;
//   static const Color textSecondary = Color(0xFF6C757D);
//   static const Color dividerColor = Color(0xFFE0E0E0);
// }
