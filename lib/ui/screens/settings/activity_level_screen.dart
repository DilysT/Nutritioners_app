import 'package:flutter/material.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String selected = 'Not very active';

  final Map<String, String> levels = {
    'Not very active':
    'You spend most of your day sitting or doing minimal physical activity.',
    'Moderately active':
    'You engage in light physical activity, like walking or occasional exercise.',
    'Active':
    'You are regularly active, exercising several times a week and moving often.',
    'Very active':
    'You have a highly active lifestyle, engaging in intense exercise or physical labor daily.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Activity level")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: levels.entries.map((entry) {
          return RadioListTile<String>(
            value: entry.key,
            groupValue: selected,
            onChanged: (value) => setState(() => selected = value!),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }
}
