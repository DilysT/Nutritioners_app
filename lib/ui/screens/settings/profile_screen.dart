import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String gender = "Male";
  DateTime? birthday;
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2003, 2, 26),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthday) {
      setState(() {
        birthday = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    heightController.text = '175';
    weightController.text = '65';
    goalController.text = '70';
    birthday = DateTime(2003, 2, 26);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Your gender", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio(
                  value: "Male",
                  groupValue: gender,
                  onChanged: (value) => setState(() => gender = value!),
                ),
                const Text("Male"),
                Radio(
                  value: "Female",
                  groupValue: gender,
                  onChanged: (value) => setState(() => gender = value!),
                ),
                const Text("Female"),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Your birthday", style: TextStyle(fontWeight: FontWeight.bold)),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  birthday != null
                      ? "${birthday!.day.toString().padLeft(2, '0')}/${birthday!.month.toString().padLeft(2, '0')}/${birthday!.year}"
                      : "Select date",
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabeledField("Height", heightController, "cm"),
            _buildLabeledField("Current weight", weightController, "kg"),
            _buildLabeledField("Weight goal", goalController, "kg"),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
