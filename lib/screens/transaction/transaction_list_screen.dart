import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pencatat_keuangan/config/app_theme.dart';
import 'package:pencatat_keuangan/providers/transaction_provider.dart';
import 'package:pencatat_keuangan/widgets/transaction_card.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);

    // Group transactions by date
    final grouped = <String, List<dynamic>>{};
    for (final tx in txState.transactions) {
      final key = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: txState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(transactionProvider.notifier).fetchTransactions(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final dateKey = sortedKeys[index];
                  final transactions = grouped[dateKey]!;
                  final date = DateTime.parse(dateKey);

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final txDate = DateTime(date.year, date.month, date.day);

                  String dateLabel;
                  if (txDate == today) {
                    dateLabel = 'Hari Ini';
                  } else if (txDate ==
                      today.subtract(const Duration(days: 1))) {
                    dateLabel = 'Kemarin';
                  } else {
                    dateLabel = DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id',
                    ).format(date);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index > 0) const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          dateLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...transactions.map((tx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    ref
                                        .read(transactionProvider.notifier)
                                        .deleteTransaction(tx.id);
                                  },
                                  backgroundColor: AppColors.expense,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Hapus',
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ],
                            ),
                            child: TransactionCard(
                              transaction: tx,
                              onTap: () {},
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
