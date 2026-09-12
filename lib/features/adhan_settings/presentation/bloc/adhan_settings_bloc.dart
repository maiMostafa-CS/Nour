import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_adhan_settings.dart';
import '../../domain/usecases/update_adhan_setting.dart';
import 'adhan_settings_event.dart';
import 'adhan_settings_state.dart';

class AdhanSettingsBloc
    extends Bloc<AdhanSettingsEvent, AdhanSettingsState> {
  final GetAdhanSettings getAdhanSettings;
  final UpdateAdhanSetting updateAdhanSetting;

  AdhanSettingsBloc({
    required this.getAdhanSettings,
    required this.updateAdhanSetting,
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

    emit(
      state.copyWith(
        status: AdhanSettingsStatus.loading,
        clearError: true,
      ),
    );

    try {
      final settings = await getAdhanSettings();

      debugPrint('📦 [AdhanSettingsBloc] Settings loaded:');
      debugPrint('   Fajr    = ${settings.fajr}');
      debugPrint('   Sunrise = ${settings.sunrise}');
      debugPrint('   Dhuhr   = ${settings.dhuhr}');
      debugPrint('   Asr     = ${settings.asr}');
      debugPrint('   Maghrib = ${settings.maghrib}');
      debugPrint('   Isha    = ${settings.isha}');

      emit(
        state.copyWith(
          status: AdhanSettingsStatus.loaded,
          settings: settings,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AdhanSettingsBloc] LOAD ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      emit(
        state.copyWith(
          status: AdhanSettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onToggleAdhanSetting(
      ToggleAdhanSetting event,
      Emitter<AdhanSettingsState> emit,
      ) async {
    final previousSettings = state.settings;

    debugPrint('════════════════════════════════════');
    debugPrint('🔄 [AdhanSettingsBloc] TOGGLE');
    debugPrint('════════════════════════════════════');

    debugPrint(
      '📌 prayerIndex = ${event.prayerIndex}',
    );

    debugPrint(
      '📌 new enabled = ${event.enabled}',
    );

    debugPrint('📦 Previous settings:');
    debugPrint('   Fajr    = ${previousSettings.fajr}');
    debugPrint('   Sunrise = ${previousSettings.sunrise}');
    debugPrint('   Dhuhr   = ${previousSettings.dhuhr}');
    debugPrint('   Asr     = ${previousSettings.asr}');
    debugPrint('   Maghrib = ${previousSettings.maghrib}');
    debugPrint('   Isha    = ${previousSettings.isha}');

    emit(
      state.copyWith(
        status: AdhanSettingsStatus.updating,
        clearError: true,
      ),
    );

    try {
      final updatedSettings = await updateAdhanSetting(
        currentSettings: previousSettings,
        prayerIndex: event.prayerIndex,
        enabled: event.enabled,
      );

      debugPrint('✅ [AdhanSettingsBloc] Updated settings:');
      debugPrint('   Fajr    = ${updatedSettings.fajr}');
      debugPrint('   Sunrise = ${updatedSettings.sunrise}');
      debugPrint('   Dhuhr   = ${updatedSettings.dhuhr}');
      debugPrint('   Asr     = ${updatedSettings.asr}');
      debugPrint('   Maghrib = ${updatedSettings.maghrib}');
      debugPrint('   Isha    = ${updatedSettings.isha}');

      emit(
        state.copyWith(
          status: AdhanSettingsStatus.loaded,
          settings: updatedSettings,
          clearError: true,
        ),
      );

      debugPrint('✅ [AdhanSettingsBloc] STATE UPDATED');
      debugPrint('════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('❌ [AdhanSettingsBloc] TOGGLE ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      emit(
        state.copyWith(
          status: AdhanSettingsStatus.error,
          settings: previousSettings,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}