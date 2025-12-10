import 'package:flutter/material.dart';

import '../model/todo.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onUpdate;

  const TodoDetailPage({super.key, required this.todo, required this.onUpdate});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late TextEditingController _controller;
  late bool _done;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo.titre);
    _descController = TextEditingController(text: widget.todo.description);
    _done = widget.todo.accompli;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détails de la tâche")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Tâche"),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            Row(
              children: [
                Checkbox(
                  value: _done,
                  onChanged: (value) {
                    setState(() {
                      _done = value!;
                    });
                  },
                ),
                Text("Terminée")
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Met à jour la tâche et revient en arrière
                widget.onUpdate(Todo(titre: _controller.text, description: _descController.text, accompli: _done));
                Navigator.pop(context);
              },
              child: Text("Enregistrer"),
            )
          ],
        ),
      ),
    );
  }
}
