import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildCitiesScreen extends StatefulWidget {
  final List<dynamic> locations;
  final String countryCode;
  final String countryName;
  final Function(dynamic location) onCitySelected;

  const BuildCitiesScreen({
    super.key,
    required this.locations,
    required this.countryCode,
    required this.countryName,
    required this.onCitySelected,
  });

  @override
  State<BuildCitiesScreen> createState() =>
      _BuildCitiesScreenState();
}

class _BuildCitiesScreenState
    extends State<BuildCitiesScreen> {

  late List<dynamic> cities;

  @override
  void initState() {
    super.initState();

    cities = widget.locations
        .where(
          (location) =>
      location.countryCode == widget.countryCode,
    )
        .toList();

    cities.sort(
          (a, b) => a.city.compareTo(b.city),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.countryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),

      body: cities.isEmpty
          ? Center(
        child: Text(
          'لم يتم العثور على مدن',
          style: TextStyle(
            fontSize: 14.sp,
          ),
        ),
      )
          : ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: cities.length,
        separatorBuilder: (_, __) =>
            SizedBox(height: 8.h),

        itemBuilder: (
            context,
            index,
            ) {
          final city = cities[index];

          return Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 6.h,
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
                  Icons.location_city,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                  size: 22.sp,
                ),
              ),

              title: Text(
                city.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),

              subtitle: Text(
                '${city.latitude}, ${city.longitude}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                ),
              ),

              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
              ),

              onTap: () {
                widget.onCitySelected(city);
              },
            ),
          );
        },
      ),
    );
  }
}