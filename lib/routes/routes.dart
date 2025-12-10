import 'package:todo_work_sessions/pages/home_page.dart';
import 'package:todo_work_sessions/pages/todo_detail.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/todo-detail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TodoDetailPage(
            todo: args['todo'],
            onUpdate: args['onUpdate'],
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => HomePage());
    }
  }
}
