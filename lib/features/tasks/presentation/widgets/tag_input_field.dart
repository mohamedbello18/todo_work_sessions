// lib/features/tasks/presentation/widgets/tag_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/task_providers.dart';

class TagInputField extends ConsumerStatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onChanged;

  const TagInputField({
    super.key,
    required this.initialTags,
    required this.onChanged,
  });

  @override
  ConsumerState<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends ConsumerState<TagInputField> {
  late List<String> _tags;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      widget.onChanged(_tags);
      _textController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final filteredSuggestions = allTags.where((t) => !_tags.contains(t) && t.toLowerCase().startsWith(_textController.text.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _tags.map((tag) => Chip(
            label: Text(tag),
            onDeleted: () => _removeTag(tag),
          )).toList(),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return allTags.where((String option) {
              return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase()) && !_tags.contains(option);
            });
          },
          onSelected: (String selection) {
            _addTag(selection);
          },
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: const InputDecoration(labelText: 'Ajouter une étiquette...'),
              onSubmitted: (String value) {
                onFieldSubmitted(); // Important pour nettoyer les options d'autocomplétion
                _addTag(value);
              },
            );
          },
        ),
      ],
    );
  }
}
