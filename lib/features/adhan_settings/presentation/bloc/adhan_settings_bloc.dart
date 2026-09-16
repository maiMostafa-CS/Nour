import 'dart:async';   // ← ضيف ده عشان unawaited

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
import '../../domain/entities/adhan_settings_entity.dart';
import '../../domain/usecases/get_adhan_settings.dart';
import '../../domain/usecases/update_adhan_setting.dart';
import 'adhan_settings_event.dart';
import 'adhan_settings_state.dart';

class AdhanSettingsBloc
    extends Bloc<AdhanSettingsEvent, AdhanSettingsState> {
  final GetAdhanSettings getAdhanSettings;
  final UpdateAdhanSetting updateAdhanSetting;
  final PrayerNotificationLocalDataSourceImpl prayerScheduler;

  /// منع تعارض العمليات اللي في الخلفية
  /// لو المستخدم ضغط بسرعة على أكتر من صلاة، بنستنى اللي قبلها
  Future<void>? _pendingReschedule;

  AdhanSettingsBloc({
    required this.getAdhanSettings,
    required this.updateAdhanSetting,
    required this.prayerScheduler,
  }) : super(const AdhanSettingsState()) {
    on<LoadAdhanSettings>(_onLoadAdhanSettings);
    on<ToggleAdhanSetting>(_onToggleAdhanSetting);
  }

  Future<void> _onLoadAdhanSettings(
      LoadAdhanSettings event,
      Emitter<AdhanSettingsState> emit,
      ) async {
    debugPrint('════════════════════════════════════');
    debugPrint('📥 [AdhanSettingsBloc] LOAD SETTINGS');
    debugPrint('════════════════════════════════════');

    emit(state.copyWith(
      status: AdhanSettingsStatus.loading,
      clearError: true,
    ));

    try {
      final settings = await getAdhanSettings();

      emit(state.copyWith(
        status: AdhanSettingsStatus.loaded,
        settings: settings,
        clearError: true,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ [AdhanSettingsBloc] LOAD ERROR: $e');
      emit(state.copyWith(
        status: AdhanSettingsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ============================================================
  // TOGGLE — OPTIMISTIC UI + BACKGROUND RESCHEDULE
  // ============================================================

  Future<void> _onToggleAdhanSetting(
      ToggleAdhanSetting event,
      Emitter<AdhanSettingsState> emit,
      ) async {
    final previousSettings = state.settings;

    debugPrint('════════════════════════════════════');
    debugPrint('🔄 [AdhanSettingsBloc] TOGGLE');
    debugPrint('📌 prayerIndex = ${event.prayerIndex}');
    debugPrint('📌 new enabled = ${event.enabled}');
    debugPrint('════════════════════════════════════');

    // ═══════════════════════════════════════════════════════
    // 1) OPTIMISTIC UPDATE — حدّث الـ UI فوراً
    // ═══════════════════════════════════════════════════════

    final optimisticSettings = previousSettings.toggle(
      event.prayerIndex,
      event.enabled,
    );

    emit(state.copyWith(
      status: AdhanSettingsStatus.loaded,
      settings: optimisticSettings,
      clearError: true,
    ));

    debugPrint('⚡ [Bloc] UI updated (optimistic)');

    // ═══════════════════════════════════════════════════════
    // 2) BACKGROUND WORK — احفظ + أعد الجدولة
    // ═══════════════════════════════════════════════════════

    _pendingReschedule = _persistAndReschedule(
      previous: previousSettings,
      optimistic: optimisticSettings,
      index: event.prayerIndex,
      enabled: event.enabled,
    );

    unawaited(_pendingReschedule!);
  }

  // ============================================================
  // PERSIST + RESCHEDULE (BACKGROUND)
  // ============================================================

  Future<void> _persistAndReschedule({
    required dynamic previous,
    required dynamic optimistic,
    required int index,
    required bool enabled,
  }) async {
    try {
      final updatedSettings = await updateAdhanSetting(
        currentSettings: previous,
        prayerIndex: index,
        enabled: enabled,
      );

      debugPrint('✅ [Bloc] Saved to prefs');

      final location = await prayerScheduler.getScheduledLocation();

      if (location == null) {
        debugPrint('⚠️ [Bloc] No saved location → skip reschedule');
        return;
      }

      await prayerScheduler.forceReschedule(
        latitude: location.$1,
        longitude: location.$2,
        days: 7,
      );

      debugPrint('✅ [Bloc] Background reschedule done');
    } catch (e, stackTrace) {
      debugPrint('❌ [Bloc] Background reschedule failed: $e');
      debugPrint('$stackTrace');

    }
  }

  // ============================================================
  // HELPER — copyWithToggle
  // ============================================================

}