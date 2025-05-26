import 'package:flutter/material.dart';

class UserData with ChangeNotifier {
  String? _date;
  String? _name;
  String? _height;
  String? _weight;
  String? _birthday;
  String? _gender;
  String? _goal_type;
  String? _weight_goal;
  String? _email;
  String? _password;
  String? _activity_level;

  String? get date => _date;

  set date(String? value) {
    _date = value;
  }

  String? get name => _name;

  set name(String? value) {
    _name = value;
  }

  String? get weight_goal => _weight_goal;

  set weight_goal(String? value) {
    _weight_goal = value;
  }

  String? get goal_type => _goal_type;

  set goal_type(String? value) {
    _goal_type = value;
  }

  String? get gender => _gender;

  set gender(String? value) {
    _gender = value;
  }

  String? get birthday => _birthday;

  set birthday(String? value) {
    _birthday = value;
  }

  String? get weight => _weight;

  set weight(String? value) {
    _weight = value;
  }

  String? get height => _height;

  set height(String? value) {
    _height = value;
  }

  String? get password => _password;

  set password(String? value) {
    _password = value;
  }

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  String? get activity_level => _activity_level;

  set activity_level(String? value) {
    _activity_level = value;
  }
}