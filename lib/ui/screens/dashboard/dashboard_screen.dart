import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../services/api_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //DateTime selectedDate = DateTime.now();
  DateTime selectedDate = DateTime.parse("2024-11-12"); // ✅ Đúng

  Map<String, dynamic>? diaryData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      print("Fetching for $formattedDate");
      final data = await ApiDashboardService.fetchDashboardData(formattedDate);
      print("Response: $data");

      if (data != null && data.containsKey('diary')) {
        setState(() {
          diaryData = data['diary'];
        });
      } else {
        print("No 'diary' in data");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
    _fetchData();
  }

  void _goToNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
    _fetchData();
  }

  String _getDisplayDate() {
    final now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return 'Today';
    }
    return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
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
      _fetchData();
    }
  }

  Widget _buildEnergySummary() {
    if (diaryData == null) return const CircularProgressIndicator();

    double consumed = double.parse(diaryData!['calories_consumed']);
    double remaining = double.parse(diaryData!['calories_remaining']);
    double total = consumed + remaining;

    Widget _buildCircle(String label, double kcal, Color color) {
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: total == 0 ? 0 : kcal / total,
                  strokeWidth: 10,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${kcal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Kcal', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircle("Calorie consumed", consumed, Colors.blue),
          _buildCircle("Calorie remaining", remaining, Colors.cyan),
        ],
      ),
    );
  }

  Widget _buildMacroTargets() {
    if (diaryData == null) return const SizedBox();

    double getDouble(String key) => double.tryParse(diaryData![key] ?? '0') ?? 0;

    double protein = getDouble('protein_consumed');
    double proteinTarget = protein + getDouble('protein_remaining');

    double fat = getDouble('fat_consumed');
    double fatTarget = fat + getDouble('fat_remaining');

    double carbs = getDouble('carbs_consumed');
    double carbsTarget = carbs + getDouble('carbs_remaining');

    Widget _buildMacro(String title, double current, double goal) {
      double progress = goal == 0 ? 0 : current / goal;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${current.toStringAsFixed(1)}/${goal.toStringAsFixed(1)} (g)',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(title, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                ),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMacro("Protein", protein, proteinTarget),
          _buildMacro("Fat", fat, fatTarget),
          _buildMacro("Carb", carbs, carbsTarget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Welcome back, John 👋",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Icon(Icons.notifications_none),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: _goToPreviousDay,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _getDisplayDate(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: _goToNextDay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildEnergySummary(),
              const SizedBox(height: 20),
              _buildMacroTargets(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
