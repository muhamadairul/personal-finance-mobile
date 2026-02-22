import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/transaction.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

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
  final ApiService _apiService = ApiService();

  TransactionNotifier() : super(const TransactionState());

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConfig.transactions);
      final List data = response.data['data'];
      final transactions = data
          .map((json) => Transaction.fromJson(json))
          .toList();
      state = TransactionState(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat transaksi');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final response = await _apiService.post(
        ApiConfig.transactions,
        data: transaction.toJson(),
      );
      final newTransaction = Transaction.fromJson(response.data['data']);
      state = state.copyWith(
        transactions: [newTransaction, ...state.transactions],
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal menambah transaksi');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.transactions}/${transaction.id}',
        data: transaction.toJson(),
      );
      final updated = Transaction.fromJson(response.data['data']);
      state = state.copyWith(
        transactions: state.transactions.map((t) {
          return t.id == updated.id ? updated : t;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal mengubah transaksi');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _apiService.delete('${ApiConfig.transactions}/$id');
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus transaksi');
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier();
    });
