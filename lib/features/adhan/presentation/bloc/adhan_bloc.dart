import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
import '../../domain/entities/adhan_reciter_entity.dart';
import '../../domain/usecases/get_adhans.dart';
import '../../domain/usecases/get_selected_adhan.dart';
import '../../domain/usecases/save_selected_adhan.dart';

import 'adhan_event.dart';
import 'adhan_state.dart';

class AdhanBloc extends Bloc<AdhanEvent, AdhanState> {
  final GetAdhans getAdhans;
  final GetSelectedAdhan getSelectedAdhan;
  final SaveSelectedAdhan saveSelectedAdhan;
  final PrayerNotificationLocalDataSourceImpl prayerScheduler;   // ← جديد

  AdhanBloc({
    required this.getAdhans,
    required this.getSelectedAdhan,
    required this.saveSelectedAdhan,
    required this.prayerScheduler,   // ← جديد
  }) : super(const AdhanInitial()) {
    on<LoadAdhanReciters>(_onLoadReciters);
    on<SelectAdhanReciter>(_onSelectReciter);
  }

  Future<void> _onLoadReciters(
      LoadAdhanReciters event,
      Emitter<AdhanState> emit,
      ) async {
    emit(const AdhanLoading());

    try {
      final reciters = await getAdhans();
      final savedId = await getSelectedAdhan();
      final selectedId = savedId ??
          (reciters.isNotEmpty ? reciters.first.id : '');

      emit(
        AdhanLoaded(
          reciters: reciters,
          selectedReciterId: selectedId,
        ),
      );
    } catch (e) {
      emit(AdhanError(e.toString()));
    }
  }

  Future<void> _onSelectReciter(
      SelectAdhanReciter event,
      Emitter<AdhanState> emit,
      ) async {
    final currentState = state;

    if (currentState is! AdhanLoaded) return;

    // 1) احفظ المؤذن الجديد
    await saveSelectedAdhan(event.reciterId);

    debugPrint('🎙️ [AdhanBloc] Reciter saved: ${event.reciterId}');

    // 2) 🔥 أعد جدولة الأذانات بالصوت الجديد
    unawaited(_rescheduleAdhansWithNewReciter());

    // 3) حدّث الـ UI فوراً
    emit(
      AdhanLoaded(
        reciters: currentState.reciters,
        selectedReciterId: event.reciterId,
      ),
    );
  }

  // ============================================================
  // RESCHEDULE WITH NEW RECITER (BACKGROUND)
  // ============================================================

  Future<void> _rescheduleAdhansWithNewReciter() async {
    try {
      final location = await prayerScheduler.getScheduledLocation();

      if (location == null) {
        debugPrint('⚠️ [AdhanBloc] No saved location → skip reschedule');
        return;
      }

      debugPrint('🎙️ [AdhanBloc] Rescheduling with new reciter...');

      await prayerScheduler.forceReschedule(
        latitude: location.$1,
        longitude: location.$2,
        days: 7,
      );

      debugPrint('✅ [AdhanBloc] Reschedule done with new reciter');
    } catch (e, stackTrace) {
      debugPrint('❌ [AdhanBloc] Reschedule failed: $e');
      debugPrint('$stackTrace');
    }
  }
}