import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamic_app/features/locations/presentation/widgets/savelocation.dart';
import 'package:islamic_app/features/locations/presentation/widgets/show_location_confirmation.dart';

import '../bloc/bloc.dart';
import '../bloc/blocEvent.dart';
import '../pages/countrySelectionScreen.dart';

class BuildManualLocationCard extends StatefulWidget {
  const BuildManualLocationCard({
    super.key,
  });

  @override
  State<BuildManualLocationCard> createState() =>
      _BuildManualLocationCardState();
}

class _BuildManualLocationCardState
    extends State<BuildManualLocationCard> {
  String? _selectedCountryCode;
  String? _selectedCountryName;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CountrySelectionScreen(
                locations: context
                    .read<LocationBloc>()
                    .state
                    .locations,

                onCountrySelected: (
                    countryCode,
                    countryName,
                    ) {
                  _selectedCountryCode = countryCode;
                  _selectedCountryName = countryName;
                },

                onCitySelected: (location) {
                  context.read<LocationBloc>().add(
                    FindLocationByCity(
                      location.city,
                    ),
                  );

                  showLocationConfirmation(
                    context,
                    location,
                        () async {
                      Navigator.pop(context);

                      await saveLocation(
                        context,
                        latitude: location.latitude,
                        longitude: location.longitude,
                        city: location.city,
                        country: location.country,
                        timezone: location.timezone,
                        isCurrentLocation: false,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                width: 58.w,
                height: 58.h,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.public,
                  size: 28.sp,
                  color: primaryColor,
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر الموقع يدويًا',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Text(
                      'اختر الدولة والمدينة يدويًا',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                Icons.arrow_forward_ios,
                size: 17.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}