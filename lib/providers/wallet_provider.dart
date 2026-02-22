import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/wallet.dart';

class WalletState {
  final List<Wallet> wallets;
  final bool isLoading;

  const WalletState({this.wallets = const [], this.isLoading = false});

  WalletState copyWith({List<Wallet>? wallets, bool? isLoading}) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get totalBalance => wallets.fold(0, (sum, w) => sum + w.balance);
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletState());

  int _nextId = 10;

  Future<void> fetchWallets() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    state = WalletState(
      wallets: [
        Wallet(
          id: 1,
          name: 'Dompet Tunai',
          type: 'cash',
          balance: 1250000,
          icon: Icons.account_balance_wallet.codePoint,
          color: 0xFF6C63FF,
        ),
        Wallet(
          id: 2,
          name: 'Bank BCA',
          type: 'bank',
          balance: 15400000,
          icon: Icons.account_balance.codePoint,
          color: 0xFF00C853,
        ),
        Wallet(
          id: 3,
          name: 'GoPay',
          type: 'ewallet',
          balance: 450000,
          icon: Icons.payment.codePoint,
          color: 0xFF2196F3,
        ),
      ],
      isLoading: false,
    );
  }

  Future<void> addWallet(Wallet wallet) async {
    state = state.copyWith(
      wallets: [
        ...state.wallets,
        wallet.copyWith(id: _nextId++),
      ],
    );
  }

  Future<void> updateWallet(Wallet wallet) async {
    state = state.copyWith(
      wallets: state.wallets
          .map((w) => w.id == wallet.id ? wallet : w)
          .toList(),
    );
  }

  Future<void> deleteWallet(int id) async {
    state = state.copyWith(
      wallets: state.wallets.where((w) => w.id != id).toList(),
    );
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});
