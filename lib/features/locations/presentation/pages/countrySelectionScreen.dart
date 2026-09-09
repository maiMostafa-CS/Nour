import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountrySelectionScreen extends StatefulWidget {
  final List<dynamic> locations;

  final Function(
      String countryCode,
      String countryName,
      ) onCountrySelected;

  final Function(dynamic location) onCitySelected;

  const CountrySelectionScreen({
    required this.locations,
    required this.onCountrySelected,
    required this.onCitySelected,
  });

  @override
  State<CountrySelectionScreen> createState() =>
      CountrySelectionScreenState();
}

class CountrySelectionScreenState
    extends State<CountrySelectionScreen> {
  final TextEditingController _searchController =
  TextEditingController();

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
      countries[location.countryCode] =
          location.country;
    }

    final filteredCountries =
    countries.entries.where((entry) {
      if (_searchQuery.trim().isEmpty) {
        return true;
      }

      return entry.value
          .toLowerCase()
          .contains(
        _searchQuery
            .trim()
            .toLowerCase(),
      );
    }).toList();

    filteredCountries.sort(
          (a, b) => a.value.compareTo(b.value),
    );

// ==========================================================
// IF COUNTRY SELECTED
// ==========================================================

    if (_selectedCountryCode != null) {
      return _buildCitiesScreen(
        context,
        _selectedCountryCode!,
        _selectedCountryName!,
      );
    }

// ==========================================================
// COUNTRIES SCREEN
// ==========================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Country',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
// ======================================================
// SEARCH
// ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear,
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
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),

// ======================================================
// COUNTRY COUNT
// ======================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredCountries.length} countries',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ),

// ======================================================
// COUNTRY LIST
// ======================================================

          Expanded(
            child: filteredCountries.isEmpty
                ? const Center(
              child: Text(
                'No countries found',
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                24,
              ),
              itemCount:
              filteredCountries.length,
              separatorBuilder: (_, __) =>
              const Divider(
                height: 1,
              ),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final country =
                filteredCountries[index];

                return ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.public,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  title: Text(
                    country.value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),

                  onTap: () {
                    setState(() {
                      _selectedCountryCode =
                          country.key;

                      _selectedCountryName =
                          country.value;
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

// ============================================================
// CITIES SCREEN
// ============================================================

  Widget _buildCitiesScreen(
      BuildContext context,
      String countryCode,
      String countryName,
      ) {
    final cities = widget.locations
        .where(
          (location) =>
      location.countryCode ==
          countryCode,
    )
        .toList();

    cities.sort(
          (a, b) => a.city.compareTo(b.city),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          countryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: cities.isEmpty
          ? const Center(
        child: Text(
          'No cities found',
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cities.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 8),
        itemBuilder: (
            context,
            index,
            ) {
          final city = cities[index];

          return Card(
            elevation: 1,
            clipBehavior:
            Clip.antiAlias,
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),

              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_city,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              title: Text(
                city.city,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              subtitle: Text(
                '${city.latitude}, ${city.longitude}',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {
                widget.onCitySelected(
                  city,
                );
              },
            ),
          );
        },
      ),
    );
  }

}
