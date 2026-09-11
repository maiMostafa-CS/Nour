import '../repositories/adhan_repository.dart';

class GetSelectedAdhan {
  final AdhanRepository repository;

  const GetSelectedAdhan(this.repository);

  Future<String?> call() {
    return repository.getSelectedReciterId();
  }
}