import 'package:flutter/material.dart';
import 'package:pencatat_keuangan/utils/icon_helper.dart';

class Category {
  final int id;
  final String name;
  final IconData icon;
  final int color;
  final String type; // 'income' or 'expense'

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: IconHelper.getIcon(json['icon'] as int?),
      color: json['color'] as int,
      type: json['type'] as String,
    );
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] is IconData ? (map['icon'] as IconData) : IconHelper.getIcon(map['icon'] as int?),
      color: map['color'] as int,
      type: map['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color,
      'type': type,
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Color get colorValue => Color(color);
}
