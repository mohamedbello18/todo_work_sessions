# Documentation Technique du Projet : Todo Work Sessions (Version Complète)

## 1. Vision du Projet

Ce document est la **source unique de vérité** pour tout développeur travaillant sur ce projet. Il détaille l'architecture, les flux de données, l'emplacement des fichiers clés, les décisions techniques, et les leçons apprises des erreurs passées.

---

## 2. Architecture & Concepts Fondamentaux

L'application suit une architecture propre, inspirée de la Clean Architecture, et adaptée à Flutter. Elle est conçue pour être testable, maintenable et évolutive. L'état est géré par **Riverpod**.

### 2.1. Les Couches de l'Application

Chaque fonctionnalité (ex: `tasks`, `timer`, `settings`) est organisée en 4 couches, représentées par des dossiers :

1.  `domain` : Le cœur logique et pur. Contient les **modèles de données** (ex: `Task.dart`, `timer_state.dart`) et les **contrats de repository** (interfaces abstraites, ex: `task_repository.dart`). Cette couche est indépendante de tout framework, y compris Flutter et Hive.

2.  `data` : L'implémentation technique. Contient les **sources de données** et l'**implémentation concrète** des repositories (ex: `HiveTaskRepositoryImpl.dart`). C'est ici que se trouve le code qui parle "réellement" à Hive. C'est aussi ici que l'on trouve les **adaptateurs** (ex: `duration_adapter.dart`) qui traduisent des types complexes en types primitifs pour Hive.

3.  `application` : L'orchestrateur. Contient les **services** (ex: `NotificationService`) et les **providers Riverpod** (ex: `timer_notifier.dart`, `task_providers.dart`). Cette couche fait le lien entre l'interface et la couche de données. Elle écoute les actions de l'utilisateur et appelle les méthodes appropriées du repository.

4.  `presentation` : Ce que l'utilisateur voit. Contient les **écrans** (`screens`) et les **widgets** réutilisables. Ces widgets sont des `ConsumerWidget` qui écoutent les providers de la couche `application` pour s'afficher et se mettre à jour.

### 2.2. Gestion de l'État : Riverpod

- **Pourquoi ?** Pour découpler l'état de l'interface. Un widget n'est plus responsable de stocker des données ; il ne fait que "consommer" un état qui lui est fourni par un "provider". Cela rend le code plus prévisible et plus facile à tester.
- **Exemple Clé :** Le `tasksStreamProvider` dans `lib/features/tasks/application/task_providers.dart`. L'écran `TaskListScreen` l'écoute via `ref.watch(tasksStreamProvider)`. Dès que la base de données Hive change, le `HiveTaskRepositoryImpl` émet une nouvelle liste de tâches, le `tasksStreamProvider` la transmet, et `TaskListScreen` se reconstruit automatiquement pour afficher la liste à jour, sans aucune gestion manuelle de type `setState()`.

### 2.3. Couche de Données : Le Repository Pattern

- **Pourquoi ?** Pour l'abstraction. Le `TimerNotifier` ou le `TaskListScreen` ne savent pas si les données viennent d'Hive ou d'une future API Firebase. Ils demandent simplement au `TaskRepository` de `getTasks()` ou `updateTask()`. C'est le `taskRepositoryProvider` qui est responsable de fournir la bonne implémentation (`HiveTaskRepositoryImpl`). Si demain nous passons à Firebase, nous créerons un `FirebaseTaskRepositoryImpl` et nous n'aurons qu'à changer **une seule ligne** dans la déclaration du provider, sans toucher à l'interface.
- **Fichiers Clés :**
    - Contrat (le "quoi") : `lib/features/tasks/domain/repositories/task_repository.dart`
    - Implémentation (le "comment") : `lib/features/tasks/data/repositories/hive_task_repository_impl.dart`

### 2.4. Persistance Locale : Hive & `TypeAdapter`

- **Pourquoi Hive ?** C'est une base de données NoSQL clé-valeur extrêmement rapide car elle est écrite en pur Dart. Parfait pour une application mobile réactive.
- **Le Rôle des Adaptateurs :** Hive ne sait stocker que des types primitifs. Pour un objet comme `Task`, un `TypeAdapter` (généré par `hive_generator`) sert de traducteur. Pour un type comme `Duration` ou `ThemeMode`, nous avons dû créer notre propre adaptateur manuel (ex: `DurationAdapter`) qui le transforme en un entier que Hive peut comprendre.

---

## 3. Parcours des Fonctionnalités Clés

### 3.1. Affichage de la Liste des Tâches

1.  **UI (`TaskListScreen`)** : Le `build` exécute `ref.watch(tasksStreamProvider)` pour écouter le flux.
2.  **Provider (`tasksStreamProvider`)** : Exécute la méthode `getTasks()` du `taskRepositoryProvider`.
3.  **Repository (`HiveTaskRepositoryImpl`)** : La méthode `getTasks()` retourne un `Stream` qui écoute la `Box` Hive et émet la liste des tâches à chaque changement.
4.  **UI (`TaskListScreen`)** : Le `StreamProvider` reçoit la liste et reconstruit le `ListView`.

### 3.2. Démarrer une Session sur une Tâche (Workflow "Chronos")

1.  **UI (`TaskListItem`)** : L'utilisateur appuie sur l'`IconButton` "Play".
2.  **Logique `onPressed`** :
    a.  Le statut de la tâche est mis à jour (`task.status = TaskStatus.inProgress`).
    b.  `ref.read(taskRepositoryProvider).updateTask(...)` est appelé. Le `HiveTaskRepositoryImpl` exécute alors la logique "Phoenix" pour mettre à jour le champ `startedAt`.
    c.  `ref.read(activeTaskProvider.notifier).state = task;` : Le provider de la tâche active globale est mis à jour.
    d.  `ref.read(mainTabIndexProvider.notifier).state = 1;` : Le provider de navigation est mis à jour, ce qui force le `MainWrapper` à changer d'onglet.
3.  **UI (`SessionScreen`)** : Le `build` exécute `ref.watch(activeTaskProvider)` et affiche le titre de la tâche.
4.  **Application (`timer_notifier.dart`)** : Un `ref.listen` détecte le changement de `activeTaskProvider` et appelle la méthode `configureTimer()` du `TimerNotifier`, qui ajuste le mode et la durée.

### 3.3. Changer le Thème

1.  **UI (`SettingsScreen`)** : L'utilisateur appuie sur le `ListTile` "Thème".
2.  **Logique `onTap`** : La méthode `_showThemePicker` est appelée, affichant une feuille modale.
3.  **UI (Feuille Modale)** : L'utilisateur clique sur une option (ex: "Sombre").
4.  **Logique `onTap` du `ListTile`** : `ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark)` est appelé.
5.  **Application (`ThemeNotifier`)** : La méthode `setTheme` met à jour son état (`state = themeMode`) et sauvegarde le nouveau choix dans la `Box` Hive "settings".
6.  **UI (`TodoWorkSessionsApp`)** : Le `build` du `MaterialApp` exécute `ref.watch(themeNotifierProvider)`. Il détecte le changement d'état, récupère la nouvelle `ThemeMode`, et reconstruit toute l'application avec le `darkTheme` approprié.

---

## 4. Guide des Fichiers Importants

-   `lib/main.dart`: Point d'entrée. Initialise les services (Hive, Notifications) et le `ProviderScope` de Riverpod.
-   `lib/core/theme/app_theme.dart`: Fichier central pour toute la charte graphique. Contient la définition de `lightTheme` et `darkTheme`.
-   `lib/features/main_wrapper.dart`: Contient la `BottomNavigationBar` et la logique de navigation principale.
-   `lib/data/models/task.dart`: Le modèle de données de nos tâches, avec les annotations Hive (`@HiveType`, `@HiveField`).
-   `lib/features/tasks/application/task_providers.dart`: Tous les providers Riverpod liés aux tâches.
-   `lib/features/timer/application/timer_notifier.dart`: Toute la logique complexe du minuteur (start, pause, reset, double-mode, etc.).
-   `lib/features/settings/presentation/settings_screen.dart`: L'écran de paramètres, qui utilise le `themeNotifierProvider` pour changer le thème.
-   `lib/features/settings/application/theme_provider.dart`: Contient le `ThemeNotifier` qui gère le changement de thème et sa persistance dans une `Box` Hive.

---

## 5. Post-Mortem des Erreurs (Leçons Apprises)

*(Cette section est conservée car elle est cruciale pour la maintenance future)*

-   **Conflit de Thèmes (`TextStyle.lerp`) :** Notre erreur la plus grave. **Leçon :** Toujours créer des `ThemeData` en partant d'une base commune (`ThemeData.light().copyWith()`) pour garantir la compatibilité des animations de transition. Ne pas créer de `TextTheme` complexes à la main en mélangeant des styles qui ont des propriétés `inherit` différentes.
-   **Dépendances Incompatibles (`dnd`) :** Une erreur de recherche a conduit à l'utilisation d'un package (`dnd`) pour le web dans une application mobile. **Leçon :** Toujours lire la documentation d'un package et vérifier les plateformes supportées (`Linux, Android, iOS, Web`, etc.) avant de l'ajouter au `pubspec.yaml`.
-   **Couleurs Codées en Dur :** La cause de nos problèmes de lisibilité. **Leçon :** Ne jamais coder une couleur en dur dans un widget (ex: `style: TextStyle(color: Colors.grey)`). Toujours utiliser les couleurs du thème (`Theme.of(context).colorScheme.secondary`, `Theme.of(context).disabledColor`, etc.) pour garantir que l'interface s'adapte au thème.
-   **Oublis de `pub get` et de Redémarrage Complet :** La cause des erreurs `Couldn't resolve` et `MissingPluginException`. **Leçon :** `pub get` est obligatoire après chaque modification du `pubspec.yaml`. Un redémarrage complet de l'application (pas un Hot Restart) est obligatoire après l'ajout d'un package qui contient du code natif (Android, iOS).
