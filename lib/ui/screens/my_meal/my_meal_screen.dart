import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Thêm package TableCalendar
import '../../../services/api_mymeal.dart';
import '../../widgets/bottom_nav_bar.dart'; // BottomNavBar có sẵn

class MyMealScreen extends StatefulWidget {
  const MyMealScreen({super.key});

  @override
  State<MyMealScreen> createState() => _MyMealScreenState();
}

class MealItem {
  final int foodId; // Thêm trường này
  final String name;
  final int kcal;
  final int portion;
  final int size;

  MealItem({
    required this.foodId,
    required this.name,
    required this.kcal,
    required this.portion,
    required this.size,
  });
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
            kcal: double.tryParse(item['calories'] ?? '0')?.toInt() ?? 0,
            portion: item['portion'],
            size: item['size'],
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
    // In ra các tham số trước khi gọi API
    debugPrint('Adding food with parameters: MealId: ${result['mealId']}, FoodId: ${result['foodId']}, Portion: ${result['portion']}, Size: ${result['size']}, Date: $dateStr');
    try {
      await ApiService.addFoodToMeal(
        mealId: result['mealId'],
        foodId: result['foodId'],
        portion: result['portion'],
        size: result['size'],
        date: dateStr,
      );
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
        title: const Text(
          'My meal',
          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
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
        backgroundColor: Colors.white,
        elevation: 0,
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
      backgroundColor: Colors.white,
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.arrow_back_ios, size: 18),
          rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealType, List<MealItem> mealItems) {
    int totalCalories = mealItems.fold(0, (sum, item) => sum + item.kcal);
    int mealId = _mealTypeToId(mealType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '$totalCalories kcal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            subtitle: Text('${item.kcal} kcal, Portion: ${item.portion}, Size: ${item.size}g'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditFoodDialog(
                        mealId: mealId,
                        listFoodId: item.foodId, // Assuming item.foodId is the ListFood_ID
                        currentPortion: item.portion,
                        currentSize: item.size,
                        date: _formatDate(_selectedDayOrToday()),
                        onUpdated: _fetchMeals,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteFood({
                      'mealId': _mealTypeToId(mealType),
                      'foodId': item.foodId, // dùng foodId thay vì listFoodId
                    });
                  },
                ),
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      final data = await ApiService.getAllFoods();
      setState(() {
        _foodList = data['food'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading foods: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Food'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _foodList.length,
        itemBuilder: (context, index) {
          final food = _foodList[index];
          return ListTile(
            title: Text(food['name_food']),
            subtitle: Text('${food['calories']} kcal'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(food: food),
                ),
              );
              if (result != null) {
                Navigator.pop(context, result); // Quay lại và gửi dữ liệu thêm món
              }
            },
          );
        },
      ),
    );
  }
}

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _portion = 1;
  int _size = 100;
  int _mealId = 1; // Default: 1 = Breakfast

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food['name_food']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories: ${widget.food['calories']} kcal',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Meal Type:', style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: _mealId,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _mealId = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 1, child: Text('Breakfast')),
                DropdownMenuItem(value: 2, child: Text('Lunch')),
                DropdownMenuItem(value: 3, child: Text('Dinner')),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Portion:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_portion > 1) _portion--;
                    });
                  },
                ),
                Text('$_portion', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _portion++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Size (gram):', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() {
                          _size = parsed;
                        });
                      }
                    },
                    controller: TextEditingController(text: '$_size'),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'foodId': widget.food['food_id'],
                    'mealId': _mealId,
                    'portion': _portion,
                    'size': _size,
                  });
                },
                child: const Text('Add Food', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditFoodDialog extends StatefulWidget {
  final int mealId;
  final int listFoodId;
  final int currentPortion;
  final int currentSize;
  final String date;
  final VoidCallback onUpdated;

  const EditFoodDialog({
    super.key,
    required this.mealId,
    required this.listFoodId,
    required this.currentPortion,
    required this.currentSize,
    required this.date,
    required this.onUpdated,
  });

  @override
  State<EditFoodDialog> createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  late TextEditingController _portionController;
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(text: widget.currentPortion.toString());
    _sizeController = TextEditingController(text: widget.currentSize.toString());
  }

  @override
  void dispose() {
    _portionController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _updateFood() async {
    final portion = int.tryParse(_portionController.text) ?? 1;
    final size = int.tryParse(_sizeController.text) ?? 1;

    await ApiService.updateFoodInMeal(
      mealId: widget.mealId,
      listFoodId: widget.listFoodId,
      portion: portion,
      size: size,
      date: widget.date,
    );

    Navigator.of(context).pop();
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sửa món ăn'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _portionController,
            decoration: InputDecoration(labelText: 'Số lượng'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _sizeController,
            decoration: InputDecoration(labelText: 'Kích cỡ'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Hủy'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Lưu'),
          onPressed: _updateFood,
        ),
      ],
    );
  }
}
