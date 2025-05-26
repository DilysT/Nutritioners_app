class UserModel {
  final int userId;
  final String name;
  final String email;
  final String height;
  final String weight;
  final String birthday;
  final String activityLevel;
  final String gender;
  final String caloriesDaily;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.birthday,
    required this.activityLevel,
    required this.gender,
    required this.caloriesDaily,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      height: json['height'],
      weight: json['weight'],
      birthday: json['birthday'],
      activityLevel: json['activity_level'],
      gender: json['gender'],
      caloriesDaily: json['calories_daily'],
    );
  }
}

class GoalModel {
  final int goalId;
  final double weightGoal;
  final String goalType;
  final DateTime daysToGoal;

  GoalModel({
    required this.goalId,
    required this.weightGoal,
    required this.goalType,
    required this.daysToGoal,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      goalId: json['goal_id'],
      weightGoal: (json['weight_goal'] as num).toDouble(),
      goalType: json['goal_type'],
      daysToGoal: DateTime.parse(json['days_to_goal']),
    );
  }
}

class UserData {
  final UserModel user;
  final GoalModel goal;

  UserData({required this.user, required this.goal});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: UserModel.fromJson(json['user']),
      goal: GoalModel.fromJson(json['goal']),
    );
  }
}
