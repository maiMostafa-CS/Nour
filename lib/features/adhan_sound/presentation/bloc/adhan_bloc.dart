import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/prayer_scheduler_split/prayer_scheduler/data/datasources/prayer_notification_local_data_source_impl.dart';
import '../../domain/use_cases/get_adhans_for_prayer.dart';
import '../../domain/use_cases/get_selected_adhan.dart';
import '../../domain/use_cases/save_selected_adhan.dart';
import 'adhan_event.dart';
import 'adhan_state.dart';

class AdhanBloc extends Bloc<AdhanEvent, AdhanState> {
  final String prayerName;

  final GetAdhansForPrayer getAdhansForPrayer;
  final GetSelectedAdhan getSelectedAdhan;
  final SaveSelectedAdhan saveSelectedAdhan;
  final PrayerNotificationLocalDataSourceImpl prayerScheduler;

  AdhanBloc({
    required this.prayerName,
    required this.getAdhansForPrayer,
    required this.getSelectedAdhan,
    required this.saveSelectedAdhan,
    required this.prayerScheduler,
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
      final reciters = await getAdhansForPrayer(prayerName);
      final savedId = await getSelectedAdhan(prayerName);
      final selectedId =
          savedId ?? (reciters.isNotEmpty ? reciters.first.id : '');

      debugPrint(
        '🎙️ [AdhanBloc:$prayerName] LOAD | count=${reciters.length} | savedId=$savedId | selected=$selectedId',
      );

      emit(
        AdhanLoaded(
          reciters: reciters,
          selectedReciterId: selectedId,
        ),
      );
    } catch (e, st) {
      debugPrint('❌ [AdhanBloc:$prayerName] load failed: $e');
      debugPrint('$st');
      emit(AdhanError(e.toString()));
    }
  }

  Future<void> _onSelectReciter(
      SelectAdhanReciter event,
      Emitter<AdhanState> emit,
      ) async {
    final currentState = state;
    if (currentState is! AdhanLoaded) {
      debugPrint(
        '⚠️ [AdhanBloc:$prayerName] SelectAdhanReciter ignored — state is ${state.runtimeType}',
      );
      return;
    }

    // ← Diagnostic: print exactly what the UI sent
    debugPrint(
      '🎙️ [AdhanBloc:$prayerName] SELECT EVENT | reciterId=${event.reciterId} | prev=${currentState.selectedReciterId}',
    );

    // ← If the value is the same, do nothing (prevents repeated emits)
    if (currentState.selectedReciterId == event.reciterId) {
      debugPrint(
        '🎙️ [AdhanBloc:$prayerName] SKIP — same value (${event.reciterId})',
      );
      return;
    }

    try {
      // 1. Save the selection
      await saveSelectedAdhan(prayerName, event.reciterId);

      // ← Diagnostic: confirm that this is what was actually saved
      final verified = await getSelectedAdhan(prayerName);
      debugPrint(
        '🎙️ [AdhanBloc:$prayerName] SAVED | requested=${event.reciterId} | verified=$verified',
      );

      if (verified != event.reciterId) {
        debugPrint(
          '🚨 [AdhanBloc:$prayerName] MISMATCH! requested=${event.reciterId} but saved=$verified',
        );
      }

      // 2. Update the state first
      emit(
        AdhanLoaded(
          reciters: currentState.reciters,
          selectedReciterId: event.reciterId,
        ),
      );

      // 3. Then start rescheduling (after saving and updating the state)
      unawaited(_rescheduleAdhansWithNewReciter(event.reciterId));
    } catch (e, st) {
      debugPrint('❌ [AdhanBloc:$prayerName] save failed: $e');
      debugPrint('$st');
      emit(AdhanError(e.toString()));
    }
  }

  Future<void> _rescheduleAdhansWithNewReciter(String newReciterId) async {
    try {
      debugPrint(
        '🔄 [AdhanBloc:$prayerName] reschedule START | newReciter=$newReciterId',
      );

      final location = await prayerScheduler.getScheduledLocation();
      if (location == null) {
        debugPrint('⚠️ [AdhanBloc] no location → skip reschedule');
        return;
      }

      await prayerScheduler.forceReschedule(
        latitude: location.$1,
        longitude: location.$2,
        days: 7,
      );

      debugPrint('✅ [AdhanBloc:$prayerName] reschedule done');
    } catch (e, st) {
      debugPrint('❌ [AdhanBloc:$prayerName] reschedule failed: $e');
      debugPrint('$st');
    }
  }
}