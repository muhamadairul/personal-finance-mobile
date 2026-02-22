class Transaction {
  final int id;
  final String type; // 'income' or 'expense'
  final double amount;
  final int categoryId;
  final int walletId;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;

  // Transient fields (joined from related models)
  final String? categoryName;
  final int? categoryIcon;
  final int? categoryColor;
  final String? walletName;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.walletId,
    this.note,
    required this.date,
    this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.walletName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as int,
      walletId: json['wallet_id'] as int,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as int?,
      categoryColor: json['category_color'] as int?,
      walletName: json['wallet_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'wallet_id': walletId,
      'note': note,
      'date': date.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  Transaction copyWith({
    int? id,
    String? type,
    double? amount,
    int? categoryId,
    int? walletId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    String? categoryName,
    int? categoryIcon,
    int? categoryColor,
    String? walletName,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      walletName: walletName ?? this.walletName,
    );
  }
}
