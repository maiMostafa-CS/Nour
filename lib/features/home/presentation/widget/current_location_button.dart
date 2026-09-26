import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../locations/presentation/bloc/bloc.dart';
import '../../../locations/presentation/bloc/blocEvent.dart';
import '../../../locations/presentation/widgets/current_location_dialog.dart';
import '../../../locations/presentation/widgets/current_location_helper.dart';

class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({super.key});


  Future<void> _updateLocation(BuildContext context) async {

    final shouldUpdate = await showCurrentLocationDialog(context);
    if (!shouldUpdate || !context.mounted) return;

    final hasPermission =
    await CurrentLocationHelper.checkAndRequestPermission(context);
    if (!hasPermission || !context.mounted) return;

    context.read<LocationBloc>().add(
      const GetCurrentLocation(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _updateLocation(context),
      icon: const Icon(Icons.location_on_outlined,size: 20,color: AppColors.emeraldGreen,),
    );
  }
}