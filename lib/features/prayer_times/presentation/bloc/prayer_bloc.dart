import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/SchedulePrayerNotificationsParams.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/usecases/CancelPrayerNotifications.dart';
import '../../domain/usecases/ReschedulePrayerNotifications.dart';
import '../../domain/usecases/get_prayer_times.dart';

part 'prayer_event.dart';
part 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetPrayerTimes getPrayerTimes;

  PrayerBloc(this.getPrayerTimes)
      : super(const PrayerInitial()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
  }

  Future<void> _onLoadPrayerTimes(
      LoadPrayerTimes event,
      Emitter<PrayerState> emit,
      ) async {
    emit(const PrayerLoading());

    try {
      final result = await getPrayerTimes(
        latitude: event.latitude,
        longitude: event.longitude,
        date: event.date,
      );

      emit(
        PrayerLoaded(result),
      );
    } catch (e) {
      emit(
        PrayerError(
          e.toString(),
        ),
      );
    }
  }
}


class PrayerNotificationBloc
    extends Bloc<PrayerNotificationEvent, PrayerNotificationState> {
  PrayerNotificationBloc({
    required SchedulePrayerNotifications scheduleNotifications,
    required ReschedulePrayerNotifications rescheduleNotifications,
    required CancelPrayerNotifications cancelNotifications,
  })  : _scheduleNotifications = scheduleNotifications,
        _rescheduleNotifications = rescheduleNotifications,
        _cancelNotifications = cancelNotifications,
        super(const PrayerNotificationState()) {
    on<ScheduleNotificationsRequested>(_onScheduleRequested);
    on<RescheduleNotificationsRequested>(_onRescheduleRequested);
    on<CancelNotificationsRequested>(_onCancelRequested);
  }

  final SchedulePrayerNotifications _scheduleNotifications;
  final ReschedulePrayerNotifications _rescheduleNotifications;
  final CancelPrayerNotifications _cancelNotifications;

  Future<void> _onScheduleRequested(
      ScheduleNotificationsRequested event,
      Emitter<PrayerNotificationState> emit,
      ) async {
    emit(state.copyWith(status: PrayerNotificationStatus.loading));
    try {
      await _scheduleNotifications(SchedulePrayerNotificationsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        days: event.days,
      ));
      debugPrint('🚨🚨🚨 PrayerNotificationBloc EVENT RECEIVED');

      debugPrint(
        '📍 latitude=${event.latitude}, '
            'longitude=${event.longitude}, '
            'days=${event.days}',
      );
      emit(state.copyWith(
        status: PrayerNotificationStatus.scheduled,
        scheduledDays: event.days,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerNotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRescheduleRequested(
      RescheduleNotificationsRequested event,
      Emitter<PrayerNotificationState> emit,
      ) async {
    emit(state.copyWith(status: PrayerNotificationStatus.loading));
    try {
      await _rescheduleNotifications(SchedulePrayerNotificationsParams(
        latitude: event.latitude,
        longitude: event.longitude,
        days: event.days,
      ));
      emit(state.copyWith(
        status: PrayerNotificationStatus.scheduled,
        scheduledDays: event.days,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrayerNotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelRequested(
      CancelNotificationsRequested event,
      Emitter<PrayerNotificationState> emit,
      ) async {
    emit(state.copyWith(status: PrayerNotificationStatus.loading));
    try {
      await _cancelNotifications();
      emit(state.copyWith(
        status: PrayerNotificationStatus.cancelled,
        scheduledDays: 0,
      ));
    } catch (e) {

      emit(state.copyWith(
        status: PrayerNotificationStatus.failure,
        errorMessage: e.toString(),

      ));
      debugPrint('❌ PrayerNotificationBloc ERROR: $e');

    }
  }
}