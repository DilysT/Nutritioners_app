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
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
      ),body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
      children: [
        // 🖼 Hình apple nên nằm dưới cùng trong Stack
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10), // cách BottomNavBar ~10px
              child: Image.asset(
                'lib/ui/assets/diet.png', // ảnh quả táo PNG nền trong
                width: 240,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(1), // giữ nguyên độ rõ
              ),
            ),
          ),
        ),

        // 📜 Nội dung chính cuộn phía trên hình
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 150), // 👈 khoảng cách giữa Dinner và hình apple
              ],
              const SizedBox(height: 170), // giữ nguyên tổng khoảng cách
            ],
          ),
        ),
      ],
    ),
      backgroundColor: const Color(0xFFF8F9FB),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),






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
            subtitle: Text('${item.kcal} kcal, Portion: ${item.portion}, Size: ${item.size}g'),
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
                          builder: (_) => EditFoodDialog(
                            mealId: mealId,
                            listFoodId: item.foodId,
                            currentPortion: item.portion,
                            currentSize: item.size,
                            date: _formatDate(_selectedDayOrToday()),
                            onUpdated: _fetchMeals,
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

  Future<void> _fetchFoods() async {
    try {
      final data = await ApiService.getAllFoods();
      setState(() {
        _foodList = data['food'];
        _filteredFood = _foodList;
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
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FoodDetailScreen(food: food),
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

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _portion = 1;
  int _size = 100;
  int _mealId = 1;

  final Map<int, String> mealOptions = {
    1: 'Breakfast',
    2: 'Lunch',
    3: 'Dinner',
  };

  final Map<String, int> sizeOptions = {
    'large - 135g': 135,
    'small - 100g': 100,
    'cup': 75,
  };

  @override
  Widget build(BuildContext context) {
    String? selectedSize = sizeOptions.entries
        .firstWhere((entry) => entry.value == _size,
        orElse: () => const MapEntry('custom', 0))
        .key;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.food['name_food']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutritional summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('100 kcal'),
                Text('10 protein'),
                Text('20 carbs'),
                Text('10 fat'),
              ],
            ),
            const SizedBox(height: 24),

            // Serving size
            Row(
              children: [
                const Text('Serving size', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 48,
                  height: 36,
                  child: TextFormField(
                    initialValue: '$_portion',
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() => _portion = parsed);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sizeOptions.containsKey(selectedSize)
                          ? selectedSize
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      underline: const SizedBox(),
                      selectedItemBuilder: (BuildContext context) {
                        return sizeOptions.keys.map((String value) {
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      items: sizeOptions.entries.map((entry) {
                        final isSelected = entry.value == _size;
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && sizeOptions.containsKey(value)) {
                          setState(() => _size = sizeOptions[value]!);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Meal dropdown
            Row(
              children: [
                const Text('Meal', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 72),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _mealId,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      underline: const SizedBox(),
                      selectedItemBuilder: (BuildContext context) {
                        return mealOptions.entries.map((entry) {
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      items: mealOptions.entries.map((entry) {
                        final isSelected = entry.key == _mealId;
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mealId = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

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
                    'size': _size,
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add to meal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  final List<String> sizeOptions = ['large - 135g', 'small - 100g', 'cup'];
  final Map<int, String> mealOptions = {
    1: 'Breakfast',
    2: 'Lunch',
    3: 'Dinner',
  };

  String _selectedSize = 'large - 135g';
  int _selectedMeal = 1;

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

    await ApiService.updateFoodInMeal(
      mealId: _selectedMeal,
      listFoodId: widget.listFoodId,
      portion: portion,
      size: int.tryParse(_sizeController.text) ?? 1,
      date: widget.date,
    );

    Navigator.of(context).pop();
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.blue),
        title: const Text('Edit food', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('100 kcal', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('10 protein', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('20 carbs', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('10 fat', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 24),

            // Serving size
            const Text('Serving size', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 40,
                  child: TextField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSize,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      items: sizeOptions.map((size) {
                        return DropdownMenuItem(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSize = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Meal dropdown
            const Text('Meal', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<int>(
                value: _selectedMeal,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: mealOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMeal = value);
                  }
                },
              ),
            ),

            const Spacer(),

            // Discard button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Discard', style: TextStyle(color: Colors.blue)),
              ),
            ),

            const SizedBox(height: 12),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _updateFood,
                child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

