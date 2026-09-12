import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/adhan_scheduler_service.dart';
import '../../domain/usecases/get_iqama_settings.dart';
import '../../domain/usecases/update_iqama_setting.dart';

import 'iqama_settings_event.dart';
import 'iqama_settings_state.dart';

class IqamaSettingsBloc
    extends Bloc<IqamaSettingsEvent, IqamaSettingsState> {
  final GetIqamaSettings getIqamaSettings;
  final UpdateIqamaSetting updateIqamaSetting;

  IqamaSettingsBloc({
    required this.getIqamaSettings,
    required this.updateIqamaSetting,
  }) : super(const IqamaSettingsState()) {
    on<LoadIqamaSettings>(_onLoadIqamaSettings);
    on<UpdateIqamaSettingEvent>(_onUpdateIqamaSetting);
  }

  Future<void> _onLoadIqamaSettings(
      LoadIqamaSettings event,
      Emitter<IqamaSettingsState> emit,
      ) async {
    debugPrint(
      '════════════════════════════════════',
    );

    debugPrint(
      '📥 [IqamaSettingsBloc] LOAD SETTINGS',
    );

    debugPrint(
      '════════════════════════════════════',
    );

    emit(
      state.copyWith(
        status: IqamaSettingsStatus.loading,
        clearError: true,
      ),
    );

    try {
      final settings = await getIqamaSettings();

      debugPrint(
        '📦 Iqama settings loaded:',
      );

      debugPrint(
        '   Fajr    = ${settings.fajr}',
      );

      debugPrint(
        '   Sunrise = ${settings.sunrise}',
      );

      debugPrint(
        '   Dhuhr   = ${settings.dhuhr}',
      );

      debugPrint(
        '   Asr     = ${settings.asr}',
      );

      debugPrint(
        '   Maghrib = ${settings.maghrib}',
      );

      debugPrint(
        '   Isha    = ${settings.isha}',
      );

      emit(
        state.copyWith(
          status: IqamaSettingsStatus.loaded,
          settings: settings,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [IqamaSettingsBloc] LOAD ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      emit(
        state.copyWith(
          status: IqamaSettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateIqamaSetting(
      UpdateIqamaSettingEvent event,
      Emitter<IqamaSettingsState> emit,
      ) async {
    final previousSettings = state.settings;

    final safeMinutes = event.minutes.clamp(1, 60);

    debugPrint(
      '════════════════════════════════════',
    );

    debugPrint(
      '🔄 [IqamaSettingsBloc] UPDATE',
    );

    debugPrint(
      '📌 prayerIndex = ${event.prayerIndex}',
    );

    debugPrint(
      '📌 minutes = $safeMinutes',
    );

    debugPrint(
      '════════════════════════════════════',
    );

    emit(
      state.copyWith(
        status: IqamaSettingsStatus.updating,
        clearError: true,
      ),
    );

    try {
      // ============================================================
      // 1️⃣ حفظ إعداد الإقامة الجديد
      // ============================================================

      final updatedSettings = await updateIqamaSetting(
        currentSettings: previousSettings,
        prayerIndex: event.prayerIndex,
        minutes: safeMinutes,
      );

      debugPrint(
        '✅ [IqamaSettingsBloc] UPDATED',
      );

      debugPrint(
        '   Fajr    = ${updatedSettings.fajr}',
      );

      debugPrint(
        '   Sunrise = ${updatedSettings.sunrise}',
      );

      debugPrint(
        '   Dhuhr   = ${updatedSettings.dhuhr}',
      );

      debugPrint(
        '   Asr     = ${updatedSettings.asr}',
      );

      debugPrint(
        '   Maghrib = ${updatedSettings.maghrib}',
      );

      debugPrint(
        '   Isha    = ${updatedSettings.isha}',
      );

      // ============================================================
      // 2️⃣ تحديث الـ UI فورًا
      // ============================================================

      emit(
        state.copyWith(
          status: IqamaSettingsStatus.loaded,
          settings: updatedSettings,
          clearError: true,
        ),
      );

      // ============================================================
      // 3️⃣ إعادة جدولة الـ alarms
      // ============================================================

      debugPrint(
        '🔄 [IqamaSettingsBloc] '
            'Starting prayer reschedule...',
      );

      await AdhanSchedulerService()
          .reschedulePrayerNotifications();

      debugPrint(
        '✅ [IqamaSettingsBloc] '
            'Prayer schedule rescheduled successfully',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [IqamaSettingsBloc] UPDATE ERROR',
      );

      debugPrint(
        'Error: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      emit(
        state.copyWith(
          status: IqamaSettingsStatus.error,
          settings: previousSettings,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}