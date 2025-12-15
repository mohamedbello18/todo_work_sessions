// page/ajout_modification_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../providers/todo_list_provider.dart';

class AjoutModification extends StatefulWidget {
  final Todo? todo; 

  const AjoutModification({super.key, this.todo});

  @override
  State<AjoutModification> createState() => _AjoutModificationPageState();
}

class _AjoutModificationPageState extends State<AjoutModification> {
  final _formKey = GlobalKey<FormState>();
  late String _titre;
  late String _description;
  late TodoType _selectedType; 
  late DateTime _realisation;

  @override
  void initState() {
    super.initState();
    _titre = widget.todo?.titre ?? '';
    _description = widget.todo?.description ?? '';
    _selectedType = widget.todo?.type ?? TodoType.evenement;
    _realisation = widget.todo?.realisation ?? DateTime.now().add(const Duration(hours: 1));
  }

  // Sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _realisation,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      final DateTime newDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _realisation.hour,
        _realisation.minute,
      );
      setState(() {
        _realisation = newDateTime;
      });
      await _selectTime(context);
    }
  }

  // Sélecteur d'heure
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_realisation),
    );
    if (pickedTime != null) {
      setState(() {
        _realisation = DateTime(
          _realisation.year,
          _realisation.month,
          _realisation.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final todoProvider = Provider.of<TodoListProvider>(context, listen: false);
      String actionMessage = '';

      if (widget.todo == null) {
        // AJOUT
        todoProvider.addTodo(_titre, _description, _selectedType, _realisation);
        actionMessage = 'Tâche ajoutée avec succès !';
      } else {
        // MODIFICATION
        final updatedTodo = widget.todo!.copyWith(
          titre: _titre,
          description: _description,
          type: _selectedType,
          realisation: _realisation,
        );
        todoProvider.updateTodo(updatedTodo);
        actionMessage = 'Tâche modifiée avec succès !';
      }

      // Afficher la Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionMessage)),
      );

      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Ajouter une Tâche' : 'Modifier la Tâche',style: TextStyle(color: Colors.black, fontSize: 17),),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Champ Titre
              TextFormField(
                initialValue: _titre,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) => _titre = value!,
              ),
              const SizedBox(height: 16),

              // Champ Description
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 20),

              // Sélecteur de Type de Tâche
              const Text('Type de tâche:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: TodoType.values.map((type) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(getIconForType(type), size: 18),
                        const SizedBox(width: 6),
                        Text(getNameForType(type)),
                      ],
                    ),
                    selected: _selectedType == type,
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(
                      color: _selectedType == type ? Colors.white : Colors.black87,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Sélecteur de Date et Heure d'échéance
              const Text('Date et heure d\'échéance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr').format(_realisation),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar, color: Colors.blue),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(widget.todo == null ? Icons.add : Icons.save),
                  label: Text(widget.todo == null ? 'Ajouter la Tâche' : 'Enregistrer les modifications'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}