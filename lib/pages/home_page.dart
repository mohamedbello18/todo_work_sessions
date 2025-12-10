import 'package:flutter/material.dart';
import 'package:todo_work_sessions/model/todo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _todos = [];

  void showAddTodoForm(
    BuildContext context,
    Function(String titre, String description) onSubmit,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Nouvelle tâche",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: descController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final String title = titleController.text.trim();
                  final String desc = descController.text.trim();
                  if (title.isNotEmpty && desc.isNotEmpty) {
                    setState(() {
                      _todos.add(Todo(titre: title, description: desc));
                    });
                    Navigator.pop(context);
                  }
                },

                child: Text("Enregistrer"),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_todos.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Liste des todos")),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_todos[index].titre),
                    onTap: () {
                      Navigator.pushNamed(
                      context,
                      '/todo-detail',
                      arguments: {
                        'todo': _todos[index],
                        'onUpdate': (Todo updatedTodo) {
                          setState(() {
                            _todos[index] = updatedTodo;
                          });
                        }
                      },
                    );

                    },
                    trailing: Checkbox(
                      value: _todos[index].accompli,
                      onChanged: (value) {
                        setState(() {
                          _todos[index].accompli = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoForm(context, (title, desc) {
              setState(() {
                _todos.add(Todo(titre: title, description: desc));
              });
            });
          },
          child: Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("Liste des todos"), elevation: 12),
        body: Center(
          child: Text(
            "Ancune enregistrée pour le moment.\n Enregistrez votre premiere tâche",
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoForm(context, (title, desc) {
              setState(() {
                _todos.add(Todo(titre: title, description: desc));
              });
            });
          },
          child: Icon(Icons.add),
        ),
      );
    }
  }
}
