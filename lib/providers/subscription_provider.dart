import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

// ─── State ────────────────────────────────────────────────────────────────────

@immutable
class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final int durationDays;
  final String description;
  final int? savePercent;
  final List<String> benefits;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.description,
    this.savePercent,
    required this.benefits,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      durationDays: (json['duration_days'] as num).toInt(),
      description: json['description'] as String,
      savePercent: json['save_percent'] != null
          ? (json['save_percent'] as num).toInt()
          : null,
      benefits: (json['benefits'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

@immutable
class SubscriptionHistory {
  final int id;
  final String type;
  final String? planId;
  final String? status;
  final double amount;
  final String? paymentChannel;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;
  final String? notes;

  const SubscriptionHistory({
    required this.id,
    required this.type,
    this.planId,
    this.status,
    required this.amount,
    this.paymentChannel,
    this.startsAt,
    this.endsAt,
    this.createdAt,
    this.notes,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] as int,
      type: json['type'] as String,
      planId: json['plan_id'] as String?,
      status: json['status'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentChannel: json['payment_channel'] as String?,
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'] as String)
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

@immutable
class SubscriptionState {
  final bool isLoading;
  final bool isCreatingInvoice;
  final List<SubscriptionPlan> plans;
  final List<SubscriptionHistory> history;
  final bool isPro;
  final DateTime? subscriptionUntil;
  final String? invoiceUrl;
  final String? error;

  const SubscriptionState({
    this.isLoading = false,
    this.isCreatingInvoice = false,
    this.plans = const [],
    this.history = const [],
    this.isPro = false,
    this.subscriptionUntil,
    this.invoiceUrl,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isCreatingInvoice,
    List<SubscriptionPlan>? plans,
    List<SubscriptionHistory>? history,
    bool? isPro,
    DateTime? subscriptionUntil,
    String? invoiceUrl,
    String? error,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isCreatingInvoice: isCreatingInvoice ?? this.isCreatingInvoice,
      plans: plans ?? this.plans,
      history: history ?? this.history,
      isPro: isPro ?? this.isPro,
      subscriptionUntil: subscriptionUntil ?? this.subscriptionUntil,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ApiService _apiService = ApiService();

  SubscriptionNotifier() : super(const SubscriptionState());

  /// Load all subscription data (plans + status + history).
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        _loadPlans(),
        _loadStatus(),
        _loadHistory(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data langganan.',
      );
    }
  }

  Future<void> _loadPlans() async {
    try {
      final response = await _apiService.get(ApiConfig.subscriptionPlans);
      final List<dynamic> data = response.data['data'] ?? [];
      final plans = data
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(plans: plans);
    } catch (_) {}
  }

  Future<void> _loadStatus() async {
    try {
      final response = await _apiService.get(ApiConfig.subscriptionStatus);
      final data = response.data;
      state = state.copyWith(
        isPro: data['is_pro'] as bool? ?? false,
        subscriptionUntil: data['subscription_until'] != null
            ? DateTime.tryParse(data['subscription_until'] as String)
            : null,
      );
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _apiService.get(ApiConfig.subscriptionHistory);
      final List<dynamic> data = response.data['data'] ?? [];
      final history = data
          .map((e) => SubscriptionHistory.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(history: history);
    } catch (_) {}
  }

  /// Refresh status only (lightweight poll after payment).
  Future<bool> refreshStatus() async {
    try {
      final response = await _apiService.get(ApiConfig.subscriptionStatus);
      final data = response.data;
      final wasPro = state.isPro;
      state = state.copyWith(
        isPro: data['is_pro'] as bool? ?? false,
        subscriptionUntil: data['subscription_until'] != null
            ? DateTime.tryParse(data['subscription_until'] as String)
            : null,
      );
      // Return true if status changed from Free → Pro
      return !wasPro && state.isPro;
    } catch (_) {
      return false;
    }
  }

  /// Create a Xendit Invoice and return the payment URL.
  Future<String?> createInvoice(String planId) async {
    state = state.copyWith(isCreatingInvoice: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.subscriptionCreateInvoice,
        data: {'plan_id': planId},
      );
      final invoiceUrl = response.data['data']['invoice_url'] as String?;
      state = state.copyWith(
        isCreatingInvoice: false,
        invoiceUrl: invoiceUrl,
      );
      return invoiceUrl;
    } catch (e) {
      state = state.copyWith(
        isCreatingInvoice: false,
        error: 'Gagal membuat invoice pembayaran.',
      );
      return null;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
