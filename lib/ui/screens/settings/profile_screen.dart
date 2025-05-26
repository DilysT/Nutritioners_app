import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/setting_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String gender = 'male';
  DateTime? birthday;
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ApiService.getUserInformation();
    final user = data.user;
    final goal = data.goal;

    setState(() {
      gender = user.gender.toLowerCase();
      birthday = DateTime.tryParse(user.birthday);
      heightController.text = user.height;
      weightController.text = user.weight;
      goalController.text = goal.weightGoal.toString();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => birthday = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF007AFF)),
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          const Text("Your gender", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildGenderOption("male", "Male"),
              const SizedBox(width: 12),
              _buildGenderOption("female", "Female"),
            ],
          ),
          const SizedBox(height: 20),

          const Text("Your birthday", style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      birthday != null
                          ? DateFormat('dd/MM/yyyy').format(birthday!)
                          : 'Select date',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildLabeledField("Height", heightController, "cm"),
          _buildLabeledField("Current weight", weightController, "kg"),
          _buildLabeledField("Weight goal", goalController, "kg"),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: gender,
          activeColor: const Color(0xFF007AFF),
          onChanged: (val) => setState(() => gender = val!),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixText: suffix,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
