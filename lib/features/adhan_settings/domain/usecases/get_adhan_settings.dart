import '../entities/adhan_settings_entity.dart';
import '../repositories/ adhan_settings_repository.dart';

class GetAdhanSettings {
  final AdhanSettingsRepository repository;

  const GetAdhanSettings({
    required this.repository,
  });

  Future<AdhanSettingsEntity> call() async {
    return repository.getSettings();
  }
}