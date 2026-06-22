import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/error_mapper.dart';
import '../../../../data/repositories/interfaces/notifications_repository_interface.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

export 'notifications_event.dart';
export 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final INotificationsRepository _repo;
  StreamSubscription<Map<String, dynamic>>? _sub;

  NotificationsBloc({required INotificationsRepository repository})
    : _repo = repository,
      super(const NotificationsState()) {
    on<LoadNotifications>(_onLoad);
    on<RefreshNotifications>(_onRefresh);
    on<NotificationsRealtimeChanged>(_onRealtimeChanged);
    on<MarkNotificationReadRequested>(_onMarkRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    _sub ??= _repo.watchEvents().listen((event) {
      final unread = (event['unreadCount'] as num?)?.toInt();
      add(NotificationsRealtimeChanged(unreadCount: unread));
    }, onError: (_) {});
    await _loadPage(emit);
  }

  Future<void> _onRefresh(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    await _loadPage(emit);
  }

  Future<void> _loadPage(Emitter<NotificationsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final page = await _repo.list();
      emit(
        state.copyWith(
          items: page.items,
          unreadCount: page.unreadCount,
          isLoading: false,
          error: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: errorMessage(error)));
    }
  }

  Future<void> _onRealtimeChanged(
    NotificationsRealtimeChanged event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.unreadCount != null) {
      emit(state.copyWith(unreadCount: event.unreadCount));
    }
    await _loadPage(emit);
  }

  Future<void> _onMarkRead(
    MarkNotificationReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final unread = await _repo.markRead(event.messageId);
      final items = state.items
          .map(
            (item) => item.messageId == event.messageId
                ? item.copyWith(readAt: DateTime.now())
                : item,
          )
          .toList();
      emit(state.copyWith(items: items, unreadCount: unread, error: null));
    } catch (error) {
      emit(state.copyWith(error: errorMessage(error)));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
