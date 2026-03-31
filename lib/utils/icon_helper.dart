import 'package:flutter/material.dart';

class IconHelper {
  // Combine all possible icons from Categories and Wallets.
  static const List<IconData> _availableIcons = [
    // Category Icons
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.receipt_long,
    Icons.movie,
    Icons.medical_services,
    Icons.school,
    Icons.home,
    Icons.flight,
    Icons.sports_esports,
    Icons.pets,
    Icons.card_giftcard,
    Icons.account_balance_wallet,
    Icons.laptop_mac,
    Icons.trending_up,
    Icons.work,
    Icons.coffee,
    Icons.local_gas_station,
    Icons.phone_android,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.fitness_center,
    Icons.more_horiz,

    // Additional Wallet Icons
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.payment,
    Icons.money,
    Icons.currency_exchange,
    Icons.smartphone,
    Icons.store,
    Icons.business_center,
    Icons.diamond,
    Icons.attach_money,
  ];

  static final Map<int, IconData> _iconMap = {
    for (var icon in _availableIcons) icon.codePoint: icon,
  };

  /// Returns the matching IconData from the predefined list,
  /// or a fallback icon if it cannot be found.
  static IconData getIcon(int? codePoint, {IconData fallback = Icons.category}) {
    if (codePoint == null) return fallback;
    return _iconMap[codePoint] ?? fallback;
  }
}
