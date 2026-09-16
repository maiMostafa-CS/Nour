import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/quran_bloc.dart';
import '../widgets/quran_index_view.dart';



class QuranIndexPage extends StatelessWidget {
  const QuranIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuranBloc>(
      create: (_) => sl<QuranBloc>()..add(const LoadSurahs()),
      child: const QuranIndexView(),
    );
  }
}
