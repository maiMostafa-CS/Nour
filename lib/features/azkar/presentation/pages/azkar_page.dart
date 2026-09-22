import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/azkar_bloc.dart';
import '../bloc/azkar_event.dart';
import '../bloc/azkar_state.dart';

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AzkarBloc>()
        ..add(const LoadAzkarCategories()),
      child: const _AzkarView(),
    );
  }
}

class _AzkarView extends StatefulWidget {
  const _AzkarView();

  @override
  State<_AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<_AzkarView> {
  final Set<int> _hiddenItems = {};

  final Map<int, int> _remainingCounts = {};

  final List<int> _hiddenHistory = [];

  void _onItemTap(dynamic item) {
    setState(() {
      final id = item.id;

      _remainingCounts[id] ??= item.count;

      _remainingCounts[id] = _remainingCounts[id]! - 1;

      _hiddenHistory.add(id);

      if (_remainingCounts[id]! <= 0) {
        _hiddenItems.add(id);
      }
    });
  }

  void _undo() {
    if (_hiddenHistory.isEmpty) return;

    setState(() {
      final lastId = _hiddenHistory.removeLast();

      _hiddenItems.remove(lastId);

      if (_remainingCounts.containsKey(lastId)) {
        _remainingCounts[lastId] =
            _remainingCounts[lastId]! + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AzkarPage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),      ),


      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          if (state is AzkarLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AzkarError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is AzkarCategoriesLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];

                return ListTile(
                  title: Text(
                    category.name,
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () {
                    context.read<AzkarBloc>().add(
                      LoadAzkarChapters(category.id),
                    );
                  },
                );
              },
            );
          }

          if (state is AzkarChaptersLoaded) {
            return ListView.builder(
              itemCount: state.chapters.length,
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];

                return ListTile(
                  title: Text(
                    chapter.name,
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () {
                    context.read<AzkarBloc>().add(
                      LoadAzkarItems(chapter.id),
                    );
                  },
                );
              },
            );
          }

          if (state is AzkarItemsLoaded) {
            final visibleItems = state.items
                .where(
                  (item) => !_hiddenItems.contains(item.id),
            )
                .toList();

            if (visibleItems.isEmpty) {
              return const Center(
                child: Text(
                  'تم الانتهاء من الأذكار',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];

                final remaining =
                    _remainingCounts[item.id] ?? item.count;

                return GestureDetector(
                  onTap: () => _onItemTap(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF5D7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8B5A2B)
                            .withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          item.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // عدد التكرارات المتبقية
                        if (item.count > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5A2B),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$remaining',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

          return const SizedBox();
        },
      ),
    );
  }
}