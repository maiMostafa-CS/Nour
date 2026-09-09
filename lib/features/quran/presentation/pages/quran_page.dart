import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/quran_bloc.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuranBloc>()..add(const LoadQuran()),
      child: Scaffold(
        appBar: AppBar(title: const Text('القرآن الكريم')),
        body: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state is QuranLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is QuranError) return Center(child: Text(state.message));
            if (state is QuranLoaded) {
              return ListView.builder(
                itemCount: state.surahs.length,
                itemBuilder: (_, index) {
                  final surah = state.surahs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        '${surah.number}. ${surah.name}',
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(surah.englishName),
                      children: surah.ayahs.map((ayah) {
                        return Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            '${ayah.text} ۝${ayah.number}',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 20, height: 1.8),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
