# Partie 2 : Intégration Firebase (Firestore) - React Native + Flutter

Copier `NotesApp/` et `notes_app/` par-dessus le dépôt `lab1_NotesApp` (mêmes chemins).
Supprimer si présents (reste de la version Appwrite) : `NotesApp/lib/appwrite.js`, `notes_app/lib/config/`,
`notes_app/lib/services/appwrite_client.dart`, `notes_app/env.json`.

## 1. Console Firebase (console.firebase.google.com)
1. Add project > nom `NotesApp` (Google Analytics non nécessaire).
2. Build > Firestore Database > Create database > région proche > mode **test** (lecture/écriture ouvertes, temporaire).
3. Pas de colonnes à créer : la collection `notes` est créée automatiquement à la première note.
   Document : `content` (string), `createdAt` (timestamp), `updatedAt` (timestamp, après modification).
4. Règles de développement (Firestore > Rules), à remplacer en Partie 3 par des règles par utilisateur :
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if true;
    }
  }
}
```

## 2. React Native
Console : Project settings (roue dentée) > Your apps > icône Web `</>` > enregistrer l'app > copier l'objet `firebaseConfig`.
```cmd
cd NotesApp
npx expo install firebase
copy .env.example .env
```
Remplir `.env` avec les valeurs de `firebaseConfig`, puis :
```cmd
npx expo start -c
```

## 3. Flutter
Prérequis : Node.js, Firebase CLI et FlutterFire CLI.
```cmd
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
cd notes_app
flutter pub add firebase_core cloud_firestore
flutterfire configure
```
`flutterfire configure` : choisir le projet `NotesApp`, plateformes android (et web si besoin). Il génère `lib/firebase_options.dart`
(requis par `main.dart`) et configure Android. Puis :
```cmd
flutter run
```
Si erreur de build Android liée à Gradle / minSdk : dans `android/app/build.gradle.kts`, mettre `minSdk = 23`.

## 4. Vérification
Ajouter / modifier / supprimer une note, relancer l'app : les notes restent. Vérifier dans Firestore Database > Data > `notes`.

## 5. Git
Ne pas committer `.env` (NotesApp). `firebase_options.dart` contient des identifiants publics du projet : acceptable, mais la sécurité repose sur les règles Firestore.
