import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/transaction.dart';
import 'package:pencatat_keuangan/config/constants.dart';

class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState());

  int _nextId = 100;

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final mockTransactions = [
      Transaction(
        id: 1,
        type: 'expense',
        amount: 50000,
        categoryId: 1,
        walletId: 1,
        note: 'Makan Siang',
        date: now,
        categoryName: 'Makan',
        categoryIcon: Icons.restaurant.codePoint,
        categoryColor: 0xFFFF6B6B,
        walletName: 'Dompet Tunai',
      ),
      Transaction(
        id: 2,
        type: 'income',
        amount: 5000000,
        categoryId: 9,
        walletId: 2,
        note: 'Gaji Bulanan',
        date: now.subtract(const Duration(days: 1)),
        categoryName: 'Gaji',
        categoryIcon: Icons.account_balance_wallet.codePoint,
        categoryColor: 0xFF00C853,
        walletName: 'Bank BCA',
      ),
      Transaction(
        id: 3,
        type: 'expense',
        amount: 20000,
        categoryId: 2,
        walletId: 1,
        note: 'Transportasi',
        date: now.subtract(const Duration(days: 1)),
        categoryName: 'Transportasi',
        categoryIcon: Icons.directions_car.codePoint,
        categoryColor: 0xFF4ECDC4,
        walletName: 'Dompet Tunai',
      ),
      Transaction(
        id: 4,
        type: 'expense',
        amount: 150000,
        categoryId: 3,
        walletId: 2,
        note: 'Belanja Bulanan',
        date: now.subtract(const Duration(days: 3)),
        categoryName: 'Belanja',
        categoryIcon: Icons.shopping_bag.codePoint,
        categoryColor: 0xFFFFBE0B,
        walletName: 'Bank BCA',
      ),
      Transaction(
        id: 5,
        type: 'expense',
        amount: 35000,
        categoryId: 5,
        walletId: 3,
        note: 'Nonton Film',
        date: now.subtract(const Duration(days: 4)),
        categoryName: 'Hiburan',
        categoryIcon: Icons.movie.codePoint,
        categoryColor: 0xFFFF9671,
        walletName: 'GoPay',
      ),
      Transaction(
        id: 6,
        type: 'income',
        amount: 2000000,
        categoryId: 10,
        walletId: 2,
        note: 'Project Freelance',
        date: now.subtract(const Duration(days: 5)),
        categoryName: 'Freelance',
        categoryIcon: Icons.laptop_mac.codePoint,
        categoryColor: 0xFF2196F3,
        walletName: 'Bank BCA',
      ),
      Transaction(
        id: 7,
        type: 'expense',
        amount: 75000,
        categoryId: 6,
        walletId: 1,
        note: 'Obat',
        date: now.subtract(const Duration(days: 6)),
        categoryName: 'Kesehatan',
        categoryIcon: Icons.medical_services.codePoint,
        categoryColor: 0xFF00C9A7,
        walletName: 'Dompet Tunai',
      ),
    ];

    state = TransactionState(transactions: mockTransactions, isLoading: false);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final allCategories = DefaultCategories.all;
    final cat = allCategories.firstWhere(
      (c) => c['id'] == transaction.categoryId,
      orElse: () => allCategories.last,
    );

    final newTransaction = transaction.copyWith(
      id: _nextId++,
      categoryName: cat['name'] as String,
      categoryIcon: (cat['icon'] as IconData).codePoint,
      categoryColor: cat['color'] as int,
    );

    state = state.copyWith(
      transactions: [newTransaction, ...state.transactions],
    );
  }

  Future<void> deleteTransaction(int id) async {
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = state.copyWith(
      transactions: state.transactions.map((t) {
        return t.id == transaction.id ? transaction : t;
      }).toList(),
    );
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier();
    });
