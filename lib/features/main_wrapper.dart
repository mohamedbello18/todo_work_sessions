// lib/features/main_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_work_sessions/features/application/application_providers.dart';
import 'package:todo_work_sessions/features/settings/presentation/settings_screen.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_edit_screen.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_list_screen.dart';
import 'package:todo_work_sessions/features/timer/presentation/session_screen.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    const TaskListScreen(),
    const SessionScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainTabIndexProvider);

    void onItemTapped(int index) {
      ref.read(mainTabIndexProvider.notifier).state = index;
    }

    void navigateToEditScreen() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TaskEditScreen()),
      );
    }

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(selectedIndex),
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: navigateToEditScreen,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'Tâches'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Minuteur'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.secondary, 
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
