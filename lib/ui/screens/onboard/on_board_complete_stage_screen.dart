import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrition_app/models/user_data.dart';
import 'package:nutrition_app/ui/screens/onboard/on_board_summary_screen.dart';
import 'package:provider/provider.dart';

class OnBoardCompleteStage extends StatefulWidget {
  const OnBoardCompleteStage({super.key});

  @override
  State<OnBoardCompleteStage> createState() => _OnBoardCompleteStage();
}

class _OnBoardCompleteStage extends State<OnBoardCompleteStage> {
  DateTime selectedDate = DateTime.now();
  final ValueNotifier<String?> selectedGender = ValueNotifier<String?>(null);
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController weightGoalController = TextEditingController();

  bool isFormComplete() {
    return heightController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        weightGoalController.text.isNotEmpty &&
        selectedGender.value != null;
  }

  void _updateUserData() {
    final userData = Provider.of<UserData>(context, listen: false);
    userData.gender = selectedGender.value!;
    userData.birthday = "${selectedDate.toLocal()}".split(' ')[0];
    userData.height = heightController.text.trim();
    userData.weight = weightController.text.trim();
    userData.weight_goal = weightGoalController.text.trim();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _onChanged() => setState(() {}); // rebuild UI when inputs change

  @override
  void initState() {
    super.initState();
    heightController.addListener(_onChanged);
    weightController.addListener(_onChanged);
    weightGoalController.addListener(_onChanged);
    selectedGender.addListener(_onChanged);
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    weightGoalController.dispose();
    selectedGender.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = isFormComplete();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(width: 250, height: 5, color: Colors.blue),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Complete your essential information", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Your gender", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ValueListenableBuilder<String?>(
                valueListenable: selectedGender,
                builder: (context, value, _) {
                  return Row(
                    children: [
                      _genderButton("Male", value == "Male"),
                      const SizedBox(width: 10),
                      _genderButton("Female", value == "Female"),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text("Your birthday", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Select your birth date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    onPressed: () => _selectDate(context),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                controller: TextEditingController(
                  text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
              ),
              const SizedBox(height: 20),
              _numberField("Height", heightController, "cm"),
              const SizedBox(height: 20),
              _numberField("Weight", weightController, "kg"),
              const SizedBox(height: 20),
              _numberField("Goal", weightGoalController, "kg"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isComplete
                ? () {
              _updateUserData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnBoardSummaryScreen()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? const Color(0xFF0072FD) : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectedGender.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? (label == "Male" ? Colors.blue : Colors.pink) : Colors.transparent,
            border: Border.all(color: selected ? (label == "Male" ? Colors.blue : Colors.pink) : Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Type your $label',
            labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
