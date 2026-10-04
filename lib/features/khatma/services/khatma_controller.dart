import 'package:flutter/foundation.dart';
import '../domain/entities/khatma_progress.dart';

class KhatmaController {
  static final progressNotifier = ValueNotifier<KhatmaProgress?>(null);

  static void update(KhatmaProgress progress) {
    progressNotifier.value = progress;
  }
}