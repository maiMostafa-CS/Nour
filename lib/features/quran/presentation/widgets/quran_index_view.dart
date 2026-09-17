import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran_bloc.dart';
import 'mushaf_page.dart';

class QuranIndexView extends StatelessWidget {
  const QuranIndexView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF5D7),

      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('الفهرس'),
        ),
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is QuranError) {
            return Center(
              child: Text(
                'حدث خطأ:\n${state.message}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is QuranLoaded) {
            return ListView.builder(
              itemCount: state.surahs.length,
              itemBuilder: (context, index) {
                final surah = state.surahs[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${surah.number}'),
                  ),
                  title: Text(
                    surah.name,
                    textDirection: TextDirection.rtl,
                  ),
                  subtitle: Text(
                    '${surah.englishName} - ${surah.totalAyahs} آية',
                  ),
                  trailing: Text(
                    'ص ${surah.startPage}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MushafPage(
                          startPage: surah.startPage,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: Text('لا توجد بيانات'),
          );
        },
      ),
    );
  }
}// ============================================================
