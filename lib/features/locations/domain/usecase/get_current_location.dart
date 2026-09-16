import 'package:flutter/cupertino.dart';

import '../entity/current_location_entity.dart';
import '../repositories/current_location_repository.dart';

class GetCurrentLocationUseCase {
  final CurrentLocationRepository repository;

  GetCurrentLocationUseCase({
    required this.repository,
  });

  Future<CurrentLocationEntity> call() async {
    debugPrint('🎯 [GetCurrentLocationUseCase] START');
try{
 final   result=await repository.getCurrentLocation();
 debugPrint('🎯 [GetCurrentLocationUseCase] SUCCESS: $result');

 return result;
}
catch (e, st) {
  debugPrint('🎯 [GetCurrentLocationUseCase] ERROR: $e');
  debugPrint('$st');
  rethrow;
}
  }
}