import 'package:flutter/material.dart';
import '../../../services/setting_api.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? selected;

  final Map<String, String> levels = {
    'Not very active': 'You spend most of your day sitting or doing minimal physical activity.',
    'Moderately active': 'You engage in light physical activity, like walking or occasional exercise.',
    'Active': 'You are regularly active, exercising several times a week and moving often.',
    'Very active': 'You have a highly active lifestyle, engaging in intense exercise or physical labor daily.',
  };

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final data = await ApiService.getUserInformation();
    setState(() {
      selected = _formatActivityLevel(data.user.activityLevel);
    });
  }

  Future<void> _saveActivityLevel() async {
    final data = await ApiService.getUserInformation();
    final currentLevel = _formatActivityLevel(data.user.activityLevel);

    if (selected == null || selected == currentLevel) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes made.')));
      return;
    }

    final success = await ApiService.updateUserInformation({
      'activity_level': selected!.toLowerCase(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Updated successfully!' : 'Update failed.'),
    ));
  }

  String _formatActivityLevel(String level) {
    switch (level.toLowerCase()) {
      case 'not very active':
        return 'Not very active';
      case 'moderately active':
        return 'Moderately active';
      case 'active':
        return 'Active';
      case 'very active':
        return 'Very active';
      default:
      // fallback nếu dữ liệu backend trả không đúng
        return 'Not very active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF007AFF)),
        title: const Text(
          "Activity level",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          ...levels.entries.map((entry) {
            return RadioListTile<String>(
              value: entry.key,
              groupValue: selected,
              activeColor: const Color(0xFF007AFF),
              onChanged: (value) => setState(() => selected = value),
              title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            );
          }).toList(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: _saveActivityLevel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
