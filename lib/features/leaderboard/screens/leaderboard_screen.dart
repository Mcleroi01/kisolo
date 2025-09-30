import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        backgroundColor: AppColors.accentOrange,
      ),
      body: const Center(
        child: Text(
          'Écran du Classement\n(Fonctionnalité à implémenter)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
