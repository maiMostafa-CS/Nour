import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/location_model.dart';

abstract class LocationLocalDataSource {
  Future<List<LocationModel>> getLocations();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  static const String _jsonPath =
      'assets/countries_capitals/countries_capitals_coordinates.json';

  @override
  Future<List<LocationModel>> getLocations() async {
    final String jsonString = await rootBundle.loadString(_jsonPath);

    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map(
          (json) => LocationModel.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}