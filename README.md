# Argument

Une application iOS native pour sauvegarder et organiser vos arguments sous forme de notes structurées.

## 📝 Description

**Argument** est une application de prise de notes spécialement conçue pour archiver vos arguments de débat. L'objectif est de pouvoir retrouver facilement ses idées par thème, les copier-coller rapidement lors de discussions, ou les améliorer au fil du temps. L'application supporte aussi bien le contenu textuel que les images (mèmes argumentatifs).

### Concept

L'app permet de :
- Sauvegarder des arguments sous forme de notes
- Les organiser et les retrouver par recherche
- Les copier rapidement pour un débat
- Les améliorer progressivement
- Inclure des images/mèmes comme arguments visuels

## ✨ Fonctionnalités

### Structure des notes
Chaque note contient obligatoirement :
- **Titre** : Nom de l'argument (format texte)
- **Contenu** : Soit du texte libre (jusqu'à 5000+ caractères), soit une image

### Interface principale
- **Liste des notes** : Affichage optimisé pour voir un maximum de notes
- **Titre** : En gros et gras pour une lecture rapide
- **Aperçu** : Prévisualisation du contenu sur une ligne
- **Recherche** : Recherche dans les titres et contenus
- **Barre d'outils** : Interface "glass" moderne avec icônes uniquement

### Actions disponibles
- ➕ **Ajout** de nouvelles notes (texte ou image)
- 🔍 **Recherche** dans toute la base de notes
- ✏️ **Édition** des notes existantes
- 📋 **Copie** rapide du contenu
- 📤 **Partage** des arguments
- 🗑️ **Suppression** des notes obsolètes

## 🛠 Stack technique

### Plateforme
- **iOS 26.0+** (compatible iPhone et iPad)
- **Xcode 26.0** (Swift 5.0)

### Frameworks utilisés
- **SwiftUI** : Interface utilisateur déclarative moderne
- **SwiftData** : Persistance des données avec Core Data sous-jacent
- **PhotosUI** : Sélection d'images depuis la bibliothèque photo
- **UIKit** : Intégration pour certaines fonctionnalités natives

### Architecture
- **MVVM** : Architecture Model-View-ViewModel avec SwiftUI
- **Modèle de données** : `ArgumentNote` avec support texte et image
- **Navigation** : NavigationStack iOS 16+
- **Stockage** : Base de données locale avec SwiftData

## 🚀 Installation et développement

### Prérequis
- macOS 15+ (Sequoia)
- Xcode 26.0 ou plus récent
- Compte développeur Apple (pour les tests sur appareil)

### Installation
1. Cloner le repository :
```bash
git clone https://github.com/votre-username/Argument.git
cd Argument
```

2. Ouvrir le projet :
```bash
open Argument.xcodeproj
```

3. Sélectionner votre équipe de développement dans les paramètres du projet

4. Lancer l'application :
   - Simulateur : Cmd+R
   - Appareil : Connecter l'iPhone/iPad et sélectionner comme destination

### Structure du projet
```
Argument/
├── ArgumentApp.swift          # Point d'entrée de l'application
├── Models/
│   └── Item.swift            # Modèle ArgumentNote (SwiftData)
├── Views/
│   ├── ContentView.swift     # Vue principale (liste des notes)
│   ├── AddArgumentNoteView.swift    # Ajout de nouvelles notes
│   └── ArgumentNoteDetailView.swift # Détail et édition des notes
└── Tests/
    ├── ArgumentTests/        # Tests unitaires
    └── ArgumentUITests/      # Tests d'interface
```

### Configuration de développement
- **Bundle ID** : `ludovic-blondon.Argument`
- **Version** : 1.0
- **Deployment Target** : iOS 26.0
- **Swift Version** : 5.0

## 🧪 Tests

### Lancer les tests
```bash
# Tests unitaires
cmd+u

# Tests d'interface
# Dans Xcode : Product > Test ou Cmd+U
```

### Types de tests
- **ArgumentTests** : Tests unitaires du modèle de données
- **ArgumentUITests** : Tests d'interface utilisateur
- **ArgumentModelTests** : Tests spécifiques au modèle ArgumentNote

## 🎨 Design

### Philosophie
- **Minimalisme** : Interface épurée centrée sur le contenu
- **Efficacité** : Actions rapides avec icônes universelles
- **Modernité** : Effets "glass" et navigation fluide iOS 16+

### Icônes utilisées
- 🔍 **Loupe** : Recherche
- ➕ **Plus** : Ajout de note
- ✏️ **Crayon** : Édition
- 📋 **Documents** : Copie
- 📤 **Partage** : Export
- ❌ **Croix** : Fermeture
- ✅ **Coche** : Validation

## 📱 Compatibilité

- **iOS** : 26.0 minimum
- **Appareils** : iPhone et iPad
- **Orientations** : Portrait (iPhone), Portrait et Paysage (iPad)
- **Stockage** : Local uniquement (pas de synchronisation cloud)

## 🔄 Versions

### v1.0 (Actuelle)
- ✅ Interface de liste des notes
- ✅ Ajout de notes texte et image
- ✅ Recherche dans les notes
- ✅ Édition des notes existantes
- ✅ Copie rapide du contenu
- ✅ Partage des arguments
- ✅ Suppression des notes

### Roadmap future
- ☐ Catégories/tags pour organiser les arguments
- ☐ Export en différents formats (PDF, MD)
- ☐ Mode sombre
- ☐ Widget iOS
- ☐ Synchronisation iCloud (optionnelle)

## 👨‍💻 Développement

Créé par **Ludovic Blondon** - Septembre 2025

### Contribution
Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer des améliorations
- Soumettre des pull requests

---

*Application développée avec ❤️ en SwiftUI*