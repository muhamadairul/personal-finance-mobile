import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/wallet.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

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
  final ApiService _apiService = ApiService();

  WalletNotifier() : super(const WalletState());

  Future<void> fetchWallets() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConfig.wallets);
      final List data = response.data['data'];
      final wallets = data.map((json) => Wallet.fromJson(json)).toList();
      state = WalletState(wallets: wallets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      final response = await _apiService.post(
        ApiConfig.wallets,
        data: wallet.toJson(),
      );
      final newWallet = Wallet.fromJson(response.data['data']);
      state = state.copyWith(wallets: [...state.wallets, newWallet]);
    } catch (_) {}
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.wallets}/${wallet.id}',
        data: wallet.toJson(),
      );
      final updated = Wallet.fromJson(response.data['data']);
      state = state.copyWith(
        wallets: state.wallets
            .map((w) => w.id == updated.id ? updated : w)
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> deleteWallet(int id) async {
    try {
      await _apiService.delete('${ApiConfig.wallets}/$id');
      state = state.copyWith(
        wallets: state.wallets.where((w) => w.id != id).toList(),
      );
    } catch (_) {}
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});
