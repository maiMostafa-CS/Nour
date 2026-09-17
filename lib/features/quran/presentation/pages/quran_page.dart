import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../widgets/quran_index_view.dart';


class QuranIndexPage extends StatelessWidget {
  const QuranIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuranIndexBloc>(
      create: (_) => sl<QuranIndexBloc>()
        ..add( LoadSurahs()),
      child: const QuranIndexView(),
    );
  }
}
