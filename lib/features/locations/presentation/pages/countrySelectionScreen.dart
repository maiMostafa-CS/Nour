import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/build_cities_screen.dart';

class CountrySelectionScreen extends StatefulWidget {
  final List<dynamic> locations;

  final Function(
    String countryCode,
    String countryName,
  ) onCountrySelected;

  final Function(dynamic location) onCitySelected;

  const CountrySelectionScreen({
    super.key,
    required this.locations,
    required this.onCountrySelected,
    required this.onCitySelected,
  });

  @override
  State<CountrySelectionScreen> createState() => CountrySelectionScreenState();
}

class CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  String? _selectedCountryCode;
  String? _selectedCountryName;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    final countries = <String, String>{};

    for (final location in widget.locations) {
      countries[location.countryCode] = location.country;
    }

    final filteredCountries = countries.entries.where((entry) {
      if (_searchQuery.trim().isEmpty) {
        return true;
      }

      return entry.value.toLowerCase().contains(
            _searchQuery.trim().toLowerCase(),
          );
    }).toList();

    filteredCountries.sort(
      (a, b) => a.value.compareTo(b.value),
    );

// ==========================================================
// IF COUNTRY SELECTED
// ==========================================================

    if (_selectedCountryCode != null) {
      return BuildCitiesScreen(
        locations: widget.locations,
        countryCode: _selectedCountryCode!,
        countryName: _selectedCountryName!,
        onCitySelected: (location) {
          widget.onCitySelected(location);
        },
      );
    }

// ==========================================================
// COUNTRIES SCREEN
// ==========================================================

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر الدولة',
          style: TextStyle(
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
// ======================================================
// SEARCH
// ======================================================

          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              8.h,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن دولة...',
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 22.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),

// ======================================================
// COUNTRY COUNT
// ======================================================

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredCountries.length} دولة',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),

// ======================================================
// COUNTRY LIST
// ======================================================

          Expanded(
            child: filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'لم يتم العثور على دول',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      4.h,
                      16.w,
                      24.h,
                    ),
                    itemCount: filteredCountries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1.h,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final country = filteredCountries[index];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        leading: Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.public,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22.sp,
                          ),
                        ),
                        title: Text(
                          country.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCountryCode = country.key;
                            _selectedCountryName = country.value;
                          });

                          widget.onCountrySelected(
                            country.key,
                            country.value,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
