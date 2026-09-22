import '../repositories/azkar_repository.dart';

class GetAzkarCategories {
  final AzkarRepository repository;

  GetAzkarCategories(this.repository);

  List<dynamic> call() {
    return repository.getCategories();
  }
}
