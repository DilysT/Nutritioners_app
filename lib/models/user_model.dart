import 'package:flutter/material.dart';

class UserModel {
  final int userId;
  final String name;
  final String email;
  final String height;
  final String weight;
  final String birthday;
  final String activityLevel;
  final String gender;
  final String weightGoal;
  final String goalType;
  final String date;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.height,
    required this.weight,
    required this.weightGoal,
    required this.birthday,
    required this.activityLevel,
    required this.gender,
    required this.date,
    required this.goalType,
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
      date: json['date'],
      weightGoal: json['weight_goal'],
      goalType: json['weight_goal'],
    );
  }
}