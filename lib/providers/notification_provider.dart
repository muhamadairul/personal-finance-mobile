import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/services/notification_service.dart';

class NotificationState {
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({int? unreadCount, bool? isLoading}) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService = NotificationService();

  NotificationNotifier() : super(const NotificationState());

  Future<void> fetchUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    state = state.copyWith(unreadCount: count);
  }

  void decrementCount() {
    if (state.unreadCount > 0) {
      state = state.copyWith(unreadCount: state.unreadCount - 1);
    }
  }

  void resetCount() {
    state = state.copyWith(unreadCount: 0);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
