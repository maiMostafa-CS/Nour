import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/azkar_bloc.dart';
import '../bloc/azkar_event.dart';
import 'azkar_view.dart';

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;

    return BlocProvider(
      key: ValueKey(langCode),
      create: (_) => sl<AzkarBloc>()
        ..add(LoadAzkarCategories(langCode: langCode)),
      child: const AzkarView(),
    );
  }
}