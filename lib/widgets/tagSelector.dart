import 'package:flutter/material.dart';
import 'package:worldwildprova/aux/iconsMap.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class TagSelector extends StatefulWidget {
  final List<int>? selectedTags;
  final Function(List<int>) onChanged;

  const TagSelector({required this.onChanged, this.selectedTags});

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<Tag> existingTags = [];
  List<int> selectedTagsIds = [];

  Future<void> fetchTags() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.17:8000/api/tags/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        existingTags =
            data.map((tagJson) => Tag.fromJson(tagJson)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedTagsIds = widget.selectedTags ?? [];
    fetchTags();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: existingTags.map((tag) {
        return TagChip(
          tag: tag,
          selected: selectedTagsIds.contains(tag.id),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedTagsIds.add(tag.id);
              } else {
                selectedTagsIds.remove(tag.id);
              }
              widget.onChanged(selectedTagsIds);
            });
          },
        );
      }).toList(),
    );
  }
}
