# Kisolo - Application d'Apprentissage Lingala ↔ Portugais

**Kisolo** est une application mobile Flutter moderne qui permet d'apprendre le portugais en partant du lingala, similaire à Duolingo mais adaptée au contexte congolais.


### Stack Technologique

- **Frontend**: Flutter 3.5+
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **State Management**: Riverpod 2.4+
- **Authentication**: Google OAuth uniquement
- **Multimédia**: TTS (flutter_tts) + Reconnaissance vocale (speech_to_text)

### Structure du Projet

```dart
lib/
├── core/                          # Services et configuration de base
│   ├── config/
│   │   └── supabase_config.dart   # Configuration Supabase
│   ├── services/
│   │   ├── auth_service.dart      # Service d'authentification
│   │   └── database_service.dart  # Service de base de données
│   └── utils/
│       └── app_colors.dart        # Palette de couleurs
├── features/                      # Fonctionnalités organisées par domaine
│   ├── auth/                      # Authentification
│   ├── home/                      # Écran d'accueil
│   ├── lessons/                   # Leçons et apprentissage
│   ├── exams/                     # Examens et quiz
│   ├── leaderboard/               # Classement
│   └── profile/                   # Profil utilisateur
├── shared/                        # Code partagé
│   ├── providers/                 # Providers Riverpod
│   ├── widgets/                   # Widgets réutilisables
│   └── models/                    # Modèles de données partagés
└── main.dart                      # Point d'entrée de l'application
