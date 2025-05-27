import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'package:nutrition_app/services/dashboard_api.dart';
import 'package:nutrition_app/services/setting_api.dart';
import 'package:nutrition_app/models/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();
  DiaryData? diaryData;
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadDiary();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final data = await ApiService.getUserInformation();
      setState(() {
        userName = data.user.name;
      });
    } catch (e) {
      debugPrint('Failed to load user info: $e');
    }
  }

  Future<void> _loadDiary() async {
    setState(() => isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final data = await DashboardApi.getDiaryByDate(dateStr);
    setState(() {
      diaryData = data;
      isLoading = false;
    });
  }

  String _getDisplayDate() {
    final now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return 'Today';
    }
    return DateFormat('MMMM d, yyyy').format(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      _loadDiary();
    }
  }

  Widget _buildAnimatedProgressCircle({
    required double targetProgress,
    required int targetValue,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: targetProgress),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
      builder: (context, animatedProgress, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: CircularProgressIndicator(
                value: animatedProgress,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: targetValue),
              duration: const Duration(seconds: 2),
              builder: (context, animatedValue, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$animatedValue',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const Text('Kcal',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildEnergySummary() {
    if (diaryData == null) return const SizedBox();

    double consumed = diaryData!.caloriesConsumed;
    double remaining = diaryData!.caloriesRemaining;
    double total = consumed + remaining;
    double consumedPercent = total == 0 ? 0 : consumed / total;
    double remainingPercent = total == 0 ? 0 : remaining / total;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8),
              Text("Energy Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                children: [
                  _buildAnimatedProgressCircle(
                    targetProgress: consumedPercent,
                    targetValue: consumed.toInt(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  const Text("Calorie consumed",
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildAnimatedProgressCircle(
                    targetProgress: remainingPercent,
                    targetValue: remaining.toInt(),
                    color: Colors.cyan,
                  ),
                  const SizedBox(width: 20),
                  const Text("Calorie remaining",
                      style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          )
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildMacroTargets() {
    if (diaryData == null) return const SizedBox();

    Widget _buildMacroRow(String title, double current, double goal) {
      double total = current + goal;
      double progress = total == 0 ? 0 : current / total;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${current.toInt()}/${total.toInt()} (g)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                ),
                Text('${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 10)),
              ],
            )
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.fitness_center, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text("Macro Targets",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildMacroRow("Protein", diaryData!.proteinConsumed,
              diaryData!.proteinRemaining),
          _buildMacroRow(
              "Fat", diaryData!.fatConsumed, diaryData!.fatRemaining),
          _buildMacroRow(
              "Carb", diaryData!.carbsConsumed, diaryData!.carbsRemaining),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, ${userName.isNotEmpty ? userName : '...'} 👋",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4)
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: () {
                          setState(() => selectedDate =
                              selectedDate.subtract(
                                  const Duration(days: 1)));
                          _loadDiary();
                        }),
                    Expanded(
                      child: Center(
                        child: Text(_getDisplayDate(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    IconButton(
                        icon:
                        const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: () {
                          setState(() => selectedDate =
                              selectedDate.add(
                                  const Duration(days: 1)));
                          _loadDiary();
                        }),
                    IconButton(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        onPressed: () => _selectDate(context)),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              _buildEnergySummary(),
              _buildMacroTargets(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}