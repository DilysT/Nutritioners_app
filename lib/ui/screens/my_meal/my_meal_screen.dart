import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Thêm package TableCalendar
import '../../../services/mymeal_api.dart';
import '../../widgets/bottom_nav_bar.dart'; // BottomNavBar có sẵn
import '../../../models/mymeal_model.dart';
class MyMealScreen extends StatefulWidget {
  const MyMealScreen({super.key});

  @override
  State<MyMealScreen> createState() => _MyMealScreenState();
}

class _MyMealScreenState extends State<MyMealScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarVisible = false;
  bool _isLoading = false;

  Map<String, List<MealItem>> meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  DateTime _selectedDayOrToday() {
    final date = _selectedDay ?? DateTime.now();
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _createDiaryForDay(_selectedDayOrToday()); // Tạo diary khi vào ứng dụng
    _fetchMeals();
  }


  Future<void> _createDiaryForDay(DateTime date) async {
    final dateStr = _formatDate(date);
    try {
      await ApiService.createDiary(dateStr);
    } catch (e) {
      debugPrint('Error creating diary: $e');
    }
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    final dateStr = _formatDate(_selectedDayOrToday());
    debugPrint('Fetching meals for date: $dateStr');
    try {
      await _createDiaryForDay(_selectedDayOrToday()); // Tạo diary nếu chưa có

      final data = await ApiService.getMealsByDate(dateStr);

      meals = {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
      };

      if (data['food'] != null) {
        for (var item in data['food']) {
          String mealType = item['name']; // "Breakfast", "Lunch", etc.

          debugPrint('Meal type: $mealType, Food: ${item['name_food']}, Calories: ${item['calories']}');
          if (!meals.containsKey(mealType)) continue;

          meals[mealType]!.add(MealItem(
            foodId: item['food_id'],
            name: item['name_food'],
            kcal: double.tryParse(item['calories']?.toString() ?? '0')?.toInt() ?? 0,
            portion: item['portion'] ?? 1,
            fat: double.tryParse(item['fat']?.toString() ?? '0') ?? 0.0,
            protein: double.tryParse(item['protein']?.toString() ?? '0') ?? 0.0,
            carbs: double.tryParse(item['carbs']?.toString() ?? '0') ?? 0.0,
            fiber: double.tryParse(item['fiber']?.toString() ?? '0') ?? 0.0,
            cholesterol: double.tryParse(item['cholesterol']?.toString() ?? '0') ?? 0.0,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error loading meals: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addFood(Map<String, dynamic> result) async {
    final dateStr = _formatDate(_selectedDayOrToday());

    try {
      final response = await ApiService.addFoodToMeal(
        mealId: result['mealId'],
        foodId: result['foodId'],
        portion: result['portion'],
        date: dateStr,
        ingredientsList: List<Map<String, dynamic>>.from(result['ingredients_list']),
      );

      debugPrint('Add food response: $response');
      await _fetchMeals();
    } catch (e) {
      debugPrint('Error adding food: $e');
    }
  }

  Future<void> _deleteFood(Map<String, dynamic> result) async {
    final dateStr = _formatDate(_selectedDayOrToday());
    // In ra các tham số trước khi gọi API
    debugPrint('Deleting food: MealId: ${result['mealId']}, FoodId: ${result['foodId']},, Date: $dateStr');
    try {
      await ApiService.deleteFoodFromMeal(
        mealId: result['mealId'],
        foodId: result['foodId'],
        date: dateStr,
      );
      await _fetchMeals();
    } catch (e) {
      debugPrint('Error deleting food: $e');
    }
  }

  int _mealTypeToId(String mealType) {
    debugPrint('Converting meal type to ID: $mealType');
    switch (mealType) {
      case 'Breakfast':
        return 1;
      case 'Lunch':
        return 2;
      case 'Dinner':
        return 3;
      default:
        return 1;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My meal',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final dateStr = _formatDate(_selectedDayOrToday());
                    setState(() => _isLoading = true);
                    try {
                      await ApiService.generateMealFor7Days(date: dateStr);
                      await _fetchMeals();
                    } catch (e) {
                      debugPrint('Error generating meal plan: $e');
                    }
                    setState(() => _isLoading = false);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseFoodScreen()),
                );
                if (result != null) {
                  await _addFood(result);
                }
              },
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateSelector(),
            if (_isCalendarVisible) _buildCalendar(),
            const SizedBox(height: 20),
            if (!_isCalendarVisible) ...[
              _buildMealCard('Breakfast', meals['Breakfast'] ?? []),
              const SizedBox(height: 12),
              _buildMealCard('Lunch', meals['Lunch'] ?? []),
              const SizedBox(height: 12),
              _buildMealCard('Dinner', meals['Dinner'] ?? []),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      backgroundColor: const Color(0xFFF8F9FB),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              setState(() {
                _focusedDay = _focusedDay.subtract(const Duration(days: 1));
                _selectedDay = _focusedDay;
              });
              _fetchMeals();
            },
          ),
          Text(
            _selectedDay != null
                ? '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                : 'Today',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () {
              setState(() {
                _focusedDay = _focusedDay.add(const Duration(days: 1));
                _selectedDay = _focusedDay;
              });
              _fetchMeals();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              setState(() {
                _isCalendarVisible = !_isCalendarVisible;
              });
            },
          ),
        ],
      ),
    );
  }




  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _isCalendarVisible = false;
          });
          _fetchMeals();
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.blue, width: 1),
            ),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(6)), // ⬅ Vuông nhẹ
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.blue, width: 2),
            ),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(6)), // ⬅ Vuông nhẹ
          ),
          todayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          selectedTextStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          leftChevronIcon: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFE6F1FF), // ✅ Màu xanh nhạt
              borderRadius: BorderRadius.circular(6), // ✅ Bo vuông nhẹ
            ),
            child: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF1F2D3D)),
          ),
          rightChevronIcon: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFE6F1FF), // ✅ Màu xanh nhạt
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF1F2D3D)),
          ),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealType, List<MealItem> mealItems) {
    int totalCalories = mealItems.fold(0, (sum, item) => sum + item.kcal);
    int mealId = _mealTypeToId(mealType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '$totalCalories kcal',
              style: const TextStyle(fontSize: 14, color: Colors.grey,fontWeight: FontWeight.w500),
            ),
          ],
        ),
        children: mealItems.isEmpty
            ? [const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No food added.'),
        )]
            : mealItems.map((item) {
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.kcal} kcal, Portion: ${item.portion}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Row(
                  children: [
                    // Nút edit
                    InkWell(

                onTap: () {
          showDialog(
          context: context,
          builder: (_) => FutureBuilder<Map<String, dynamic>>(
          future: ApiService.getFoodAndIngredientChange(
          mealId: mealId,
          foodId: item.foodId,
          date: _formatDate(_selectedDayOrToday()),
          ),
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
          return AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load ingredients: ${snapshot.error}'),
          );
          }

          final ingredientList = snapshot.data!['food']
              .where((f) => f['food_id'] == item.foodId)
              .toList()
              .cast<Map<String, dynamic>>();

          final foodMap = {
          'food_id': item.foodId,
          'name_food': item.name,
          };

          return EditFoodDialog(
          food: foodMap,
          ingredients: ingredientList,
          mealId: mealId,
          listFoodId: item.foodId,
          currentPortion: item.portion,
          date: _formatDate(_selectedDayOrToday()),
          onUpdated: _fetchMeals, // sẽ gọi lại API load lại meal sau khi save
          );
          },
          ),
          );
          },

            borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 25,
                          color: Color(0xFF5F6C7B),
                        ),
                      ),
                    ),

                    // Nút delete
                    InkWell(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text(
                              'Are you sure want to delete the food?',
                              style: TextStyle(fontSize: 18, color: Color(0xFF007AFF)),
                            ),
                            content: const Text("You won't be able to reuse it."),
                            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await _deleteFood({
                            'mealId': _mealTypeToId(mealType),
                            'foodId': item.foodId,
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 25,
                          color: Color(0xFF5F6C7B),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChooseFoodScreen extends StatefulWidget {
  const ChooseFoodScreen({super.key});

  @override
  State<ChooseFoodScreen> createState() => _ChooseFoodScreenState();
}

class _ChooseFoodScreenState extends State<ChooseFoodScreen> {
  List<dynamic> _foodList = [];
  List<dynamic> _filteredFood = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allFoodIngredientData = [];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFood = _foodList
          .where((food) =>
          food['name_food'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  // Future<void> _fetchFoods() async {
  //   try {
  //     final data = await ApiService.getAllFoods();
  //     setState(() {
  //       _foodList = data['food'];
  //       _filteredFood = _foodList;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint('Error loading foods: $e');
  //     setState(() => _isLoading = false);
  //   }
  // }
  Future<void> _fetchFoods() async {
    try {
      final data = await ApiService.getFoodAndIngredient();
      _allFoodIngredientData = data['food'];
      final rawList = data['food'];

      // Lấy danh sách tên món ăn không trùng nhau
      final uniqueFoods = <Map<String, dynamic>>[];
      final seenFoodIds = <int>{};

      for (var item in rawList) {
        if (!seenFoodIds.contains(item['food_id'])) {
          uniqueFoods.add({
            'food_id': item['food_id'],
            'name_food': item['food_name'],
          });
          seenFoodIds.add(item['food_id']);
        }
      }

      setState(() {
        _foodList = uniqueFoods;
        _filteredFood = uniqueFoods;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your food',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF2F5FD),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredFood.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final food = _filteredFood[index];
                  return ListTile(
                    title: Text(food['name_food']),
                    trailing: InkWell(
                      onTap: () async {
                        final foodIngredients = _allFoodIngredientData
                            .where((f) => f['food_id'] == food['food_id'])
                            .toList()
                            .cast<Map<String, dynamic>>(); // THÊM cast() ở cuối

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              food: food,
                              ingredients: foodIngredients,
                            ),
                          ),
                        );
                        if (result != null) {
                          Navigator.pop(context, result);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF007AFF),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.add,
                              size: 14, color: Color(0xFF007AFF)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  final List<Map<String, dynamic>> ingredients;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.ingredients,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _mealId = 1;
  int _portion = 1;
  final Map<int, String> mealOptions = {
    1: 'Breakfast',
    2: 'Lunch',
    3: 'Dinner',
  };

  List<Map<String, dynamic>> ingredientInputs = [];

  @override
  void initState() {
    super.initState();
    ingredientInputs = widget.ingredients.map((ing) {
      final gram = ing['gram'] ?? 100;
      return {
        ...ing,
        'input_gram': gram,
        'base_gram': gram,
        'ingredient_id': ing['ingredient_id'] ?? ing['id'],
        'ingredient_name': ing['ingredient_name'] ?? ing['name'],
        'base_calories': ing['calories'] ?? 0,
        'base_protein': ing['protein'] ?? 0,
        'base_fat': ing['fat'] ?? 0,
        'base_carb': ing['carb'] ?? 0,
        'base_cholesterol': ing['cholesterol'] ?? 0,
      };
    }).toList();
  }

  Map<String, double> calculateTotalNutrition() {
    double calories = 0, protein = 0, fat = 0, carb = 0, cholesterol = 0;

    for (var ing in ingredientInputs) {
      final inputGram = ing['input_gram'];
      final baseGram = ing['base_gram'];
      final ratio = inputGram / baseGram;

      calories += (ing['base_calories'] ?? 0) * ratio;
      protein += (ing['base_protein'] ?? 0) * ratio;
      fat += (ing['base_fat'] ?? 0) * ratio;
      carb += (ing['base_carb'] ?? 0) * ratio;
      cholesterol += (ing['base_cholesterol'] ?? 0) * ratio;
    }

    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carb': carb,
      'cholesterol': cholesterol,
    };
  }


  @override
  Widget build(BuildContext context) {
    final total = calculateTotalNutrition();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food['name_food']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng dinh dưỡng toàn bộ món
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${total['calories']!.toStringAsFixed(0)} kcal'),
                Text('${total['protein']!.toStringAsFixed(1)} protein'),
                Text('${total['carb']!.toStringAsFixed(1)} carbs'),
                Text('${total['fat']!.toStringAsFixed(1)} fat'),

              ],
            ),
            const SizedBox(height: 24),

            // Ingredient list with editable gram
            const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: ingredientInputs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final ing = ingredientInputs[index];

                  final ratio = ing['input_gram'] / ing['base_gram'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ing['ingredient_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 36,
                            child: TextFormField(
                              initialValue: ing['input_gram'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'gram',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newGram = int.tryParse(value) ?? 0;
                                setState(() {
                                  ingredientInputs[index]['input_gram'] = newGram;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child:
                            Text(
                              '${((ing['calories'] ?? 0) * ratio).toStringAsFixed(1)} kcal, '
                                  '${((ing['protein'] ?? 0) * ratio).toStringAsFixed(1)}g protein, '
                                  '${((ing['fat'] ?? 0) * ratio).toStringAsFixed(1)}g fat, '
                                  '${((ing['carb'] ?? 0) * ratio).toStringAsFixed(1)}g carb, '
                                  '${((ing['cholesterol'] ?? 0) * ratio).toStringAsFixed(1)}g cholesterol',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Meal and Portion
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Meal'),
                      DropdownButton<int>(
                        value: _mealId,
                        isExpanded: true,
                        items: mealOptions.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _mealId = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Portion'),
                      SizedBox(
                        height: 40,
                        child: TextFormField(
                          initialValue: _portion.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null) {
                              setState(() => _portion = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, {
                    'foodId': widget.food['food_id'],
                    'mealId': _mealId,
                    'portion': _portion,
                    'ingredients_list': ingredientInputs.map((ing) => {
                      'ingredient_id': ing['id'],
                      'gram': ing['input_gram']
                    }).toList(),
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add to meal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditFoodDialog extends StatefulWidget {
  final Map<String, dynamic> food;
  final List<Map<String, dynamic>> ingredients;
  final int mealId;
  final int listFoodId;
  final int currentPortion;
  final String date;
  final VoidCallback onUpdated;

  const EditFoodDialog({
    super.key,
    required this.food,
    required this.ingredients,
    required this.mealId,
    required this.listFoodId,
    required this.currentPortion,
    required this.date,
    required this.onUpdated,
  });

  @override
  State<EditFoodDialog> createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  int _portion = 1;
  List<Map<String, dynamic>> ingredientInputs = [];

  @override
  void initState() {
    super.initState();
    _portion = widget.currentPortion;
    _loadInitialData(widget.ingredients);
  }

  void _loadInitialData(List<Map<String, dynamic>> rawIngredients) {
    ingredientInputs = rawIngredients.map((ing) {
      final gram = ing['gram'] ?? 100;
      return {
        ...ing,
        'input_gram': gram,
        'base_gram': gram,
        'base_calories': ing['calories'] ?? 0,
        'base_protein': ing['protein'] ?? 0,
        'base_fat': ing['fat'] ?? 0,
        'base_carb': ing['carb'] ?? 0,
        'base_cholesterol': ing['cholesterol'] ?? 0,
        'ingredient_id': ing['ingredient_id'] ?? ing['id'],
        'ingredient_name': ing['ingredient_name'] ?? ing['name'],
      };
    }).toList();
  }

  Map<String, double> calculateTotalNutrition() {
    double calories = 0, protein = 0, fat = 0, carb = 0, cholesterol = 0;

    for (var ing in ingredientInputs) {
      final ratio = ing['input_gram'] / (ing['base_gram'] ?? 100);
      calories += (ing['base_calories'] ?? 0) * ratio;
      protein += (ing['base_protein'] ?? 0) * ratio;
      fat += (ing['base_fat'] ?? 0) * ratio;
      carb += (ing['base_carb'] ?? 0) * ratio;
      cholesterol += (ing['base_cholesterol'] ?? 0) * ratio;
    }

    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carb': carb,
      'cholesterol': cholesterol,
    };
  }

  Future<void> _updateFood() async {
    final ingredientsList = ingredientInputs.map((ing) => {
      'ingredient_id': ing['ingredient_id'],
      'gram': ing['input_gram']
    }).toList();

    await ApiService.updateFoodInMeal(
      mealId: widget.mealId,
      listFoodId: widget.listFoodId,
      portion: _portion,
      date: widget.date,
      ingredientsList: ingredientsList,
    );

    final updatedData = await ApiService.getFoodAndIngredientChange(
      mealId: widget.mealId,
      foodId: widget.food['food_id'],
      date: widget.date,
    );

    if (updatedData['food'] != null && mounted) {
      _loadInitialData(List<Map<String, dynamic>>.from(updatedData['food']));
      setState(() {});
    }

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateTotalNutrition();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Food'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${total['calories']!.toStringAsFixed(0)} kcal'),
                Text('${total['protein']!.toStringAsFixed(1)} protein'),
                Text('${total['carb']!.toStringAsFixed(1)} carbs'),
                Text('${total['fat']!.toStringAsFixed(1)} fat'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: ingredientInputs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final ing = ingredientInputs[index];
                  final ratio = ing['input_gram'] / (ing['base_gram'] ?? 100);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ing['ingredient_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 36,
                            child: TextFormField(
                              initialValue: ing['input_gram'].toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'gram',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newGram = int.tryParse(value) ?? 0;
                                setState(() {
                                  ingredientInputs[index]['input_gram'] = newGram;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${(ing['base_calories'] * ratio).toStringAsFixed(1)} kcal, '
                                  '${(ing['base_protein'] * ratio).toStringAsFixed(1)}g protein, '
                                  '${(ing['base_fat'] * ratio).toStringAsFixed(1)}g fat, '
                                  '${(ing['base_carb'] * ratio).toStringAsFixed(1)}g carb, '
                                  '${(ing['base_cholesterol'] * ratio).toStringAsFixed(1)}g cholesterol',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Portion'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _portion.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() => _portion = parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Discard', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton(
                  onPressed: _updateFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
