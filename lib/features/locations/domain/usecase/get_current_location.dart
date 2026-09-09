import '../entity/current_location_entity.dart';
import '../repositories/current_location_repository.dart';

class GetCurrentLocationUseCase {
  final CurrentLocationRepository repository;

  GetCurrentLocationUseCase({
    required this.repository,
  });

  Future<CurrentLocationEntity> call() async {
    return repository.getCurrentLocation();
  }
}