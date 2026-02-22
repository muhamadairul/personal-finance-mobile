class Budget {
  final int id;
  final int categoryId;
  final double amount; // limit
  final double spent;
  final int month;
  final int year;

  // Transient
  final String? categoryName;
  final int? categoryIcon;
  final int? categoryColor;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.month,
    required this.year,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as int?,
      categoryColor: json['category_color'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'spent': spent,
      'month': month,
      'year': year,
    };
  }

  double get percentage =>
      amount > 0 ? (spent / amount * 100).clamp(0, 100) : 0;
  double get remaining => amount - spent;
  bool get isOverBudget => spent > amount;

  String get statusLabel {
    final pct = percentage;
    if (pct >= 80) return 'Hampir melebihi batas anggaran!';
    if (pct >= 50) return 'Sudah terpakai lebih dari setengah';
    return 'Masih dalam batas aman';
  }

  Budget copyWith({
    int? id,
    int? categoryId,
    double? amount,
    double? spent,
    int? month,
    int? year,
    String? categoryName,
    int? categoryIcon,
    int? categoryColor,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      month: month ?? this.month,
      year: year ?? this.year,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}
