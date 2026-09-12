import '../entities/iqama_settings_entity.dart';
import '../repositories/iqama_settings_repository.dart';

class GetIqamaSettings {
  final IqamaSettingsRepository repository;

  const GetIqamaSettings({
    required this.repository,
  });

  Future<IqamaSettingsEntity> call() {
    return repository.getSettings();
  }
}