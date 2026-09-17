import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/surah_entity.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';
import 'mushaf_page.dart';

class QuranIndexView extends StatefulWidget {
  const QuranIndexView({super.key});

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView> {
  static const Color backgroundColor = Color(0xFFFCF5D7);

  final TextEditingController _searchController =
  TextEditingController();

  static const List<bool> _meccanSurahs = [
    true, false, false, false, false, true, true, false, false, true,
    true, true, false, true, true, true, true, true, true, true,
    true, false, true, false, true, true, true, true, true, true,
    true, true, true, false, true, true, true, true, true, true,
    true, true, true, true, true, true, false, false, false, true,
    true, true, true, true, false, true, false, false, false, false,
    false, false, false, false, false, false, true, true, true, true,
    true, true, true, true, false, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, false, false, true,
    true, true, true, true, true, true, true, true, true, true,
    false, true, true, true, true,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSurahType(int surahNumber) {
    if (surahNumber < 1 ||
        surahNumber > _meccanSurahs.length) {
      return '';
    }

    return _meccanSurahs[surahNumber - 1]
        ? 'مكية'
        : 'مدنية';
  }

  void _onSearchChanged(String value) {
    context.read<QuranIndexBloc>().add(
      SearchSurahsEvent(value),
    );
  }

  void _clearSearch() {
    _searchController.clear();

    context.read<QuranIndexBloc>().add(
       ClearSurahSearch(),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'الفهرس',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // =====================================================
          // Search
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),

            child: TextField(
              controller: _searchController,

              textDirection: TextDirection.rtl,

              textAlign: TextAlign.right,

              onChanged: _onSearchChanged,

              decoration: InputDecoration(
                hintText: 'ابحث عن سورة',
                hintTextDirection: TextDirection.rtl,

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
                    : null,

                filled: true,

                fillColor: Colors.white.withValues(
                  alpha: 0.65,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: const BorderSide(
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // Quran Index
          // =====================================================

          Expanded(
            child: BlocBuilder<QuranIndexBloc,
                QuranIndexState>(
              builder: (context, state) {
                // =========================
                // Initial
                // =========================

                if (state is QuranIndexInitial) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                // =========================
                // Loading
                // =========================

                if (state is QuranIndexLoading) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                // =========================
                // Error
                // =========================

                if (state is QuranIndexError) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        textAlign:
                        TextAlign.center,
                        textDirection:
                        TextDirection.rtl,
                      ),
                    ),
                  );
                }

                // =========================
                // Loaded
                // =========================

                if (state is QuranIndexLoaded) {
                  final List<Surah> surahs =
                      state.filteredSurahs;

                  if (surahs.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد نتائج',
                        textDirection:
                        TextDirection.rtl,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    itemCount: surahs.length,

                    separatorBuilder: (_, __) {
                      return const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      );
                    },

                    itemBuilder:
                        (context, index) {
                      final Surah surah =
                      surahs[index];

                      final String surahType =
                      _getSurahType(
                        surah.number,
                      );

                      return InkWell(
                        borderRadius:
                        BorderRadius.circular(12),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MushafPage(
                                    startPage:
                                    surah.pageNumber,
                                  ),
                            ),
                          );
                        },

                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),

                          child: Row(
                            children: [
                              // =====================
                              // Page Number
                              // =====================

                              SizedBox(
                                width: 48,
                                child: Text(
                                  'ص ${surah.pageNumber}',

                                  textAlign:
                                  TextAlign.center,

                                  style:
                                  const TextStyle(
                                    fontSize: 13,
                                    color:
                                    Colors.black54,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              // =====================
                              // Surah Info
                              // =====================

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .end,

                                  children: [
                                    Text(
                                      surah.nameArabic,

                                      textDirection:
                                      TextDirection
                                          .rtl,

                                      textAlign:
                                      TextAlign.right,

                                      style:
                                      const TextStyle(
                                        fontSize: 19,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      '$surahType • '
                                          '${surah.ayahCount} آية',

                                      textDirection:
                                      TextDirection
                                          .rtl,

                                      textAlign:
                                      TextAlign.right,

                                      style:
                                      const TextStyle(
                                        fontSize: 13,
                                        color:
                                        Colors
                                            .black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              // =====================
                              // Surah Number
                              // =====================

                              Container(
                                width: 42,
                                height: 42,

                                decoration:
                                BoxDecoration(
                                  border: Border.all(
                                    color:
                                    Colors.black26,
                                  ),
                                  shape:
                                  BoxShape.circle,
                                ),

                                alignment:
                                Alignment.center,

                                child: Text(
                                  '${surah.number}',

                                  style:
                                  const TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}