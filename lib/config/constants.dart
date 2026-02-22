import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Pencatat Keuangan';
  static const String appTagline =
      'Kelola keuanganmu dengan lebih bijak hari ini.';
  static const String currency = 'Rp';

  // Wallet types
  static const String walletCash = 'cash';
  static const String walletBank = 'bank';
  static const String walletEwallet = 'ewallet';

  // Transaction types
  static const String typeIncome = 'income';
  static const String typeExpense = 'expense';
}

class DefaultCategories {
  static List<Map<String, dynamic>> get expense => [
    {
      'id': 1,
      'name': 'Makan',
      'icon': Icons.restaurant,
      'color': 0xFFFF6B6B,
      'type': 'expense',
    },
    {
      'id': 2,
      'name': 'Transportasi',
      'icon': Icons.directions_car,
      'color': 0xFF4ECDC4,
      'type': 'expense',
    },
    {
      'id': 3,
      'name': 'Belanja',
      'icon': Icons.shopping_bag,
      'color': 0xFFFFBE0B,
      'type': 'expense',
    },
    {
      'id': 4,
      'name': 'Tagihan',
      'icon': Icons.receipt_long,
      'color': 0xFF845EC2,
      'type': 'expense',
    },
    {
      'id': 5,
      'name': 'Hiburan',
      'icon': Icons.movie,
      'color': 0xFFFF9671,
      'type': 'expense',
    },
    {
      'id': 6,
      'name': 'Kesehatan',
      'icon': Icons.medical_services,
      'color': 0xFF00C9A7,
      'type': 'expense',
    },
    {
      'id': 7,
      'name': 'Pendidikan',
      'icon': Icons.school,
      'color': 0xFF4D8076,
      'type': 'expense',
    },
    {
      'id': 8,
      'name': 'Lainnya',
      'icon': Icons.more_horiz,
      'color': 0xFF8E8E93,
      'type': 'expense',
    },
  ];

  static List<Map<String, dynamic>> get income => [
    {
      'id': 9,
      'name': 'Gaji',
      'icon': Icons.account_balance_wallet,
      'color': 0xFF00C853,
      'type': 'income',
    },
    {
      'id': 10,
      'name': 'Freelance',
      'icon': Icons.laptop_mac,
      'color': 0xFF2196F3,
      'type': 'income',
    },
    {
      'id': 11,
      'name': 'Investasi',
      'icon': Icons.trending_up,
      'color': 0xFFFF9800,
      'type': 'income',
    },
    {
      'id': 12,
      'name': 'Hadiah',
      'icon': Icons.card_giftcard,
      'color': 0xFFE91E63,
      'type': 'income',
    },
    {
      'id': 13,
      'name': 'Lainnya',
      'icon': Icons.more_horiz,
      'color': 0xFF8E8E93,
      'type': 'income',
    },
  ];

  static List<Map<String, dynamic>> get all => [...expense, ...income];
}
