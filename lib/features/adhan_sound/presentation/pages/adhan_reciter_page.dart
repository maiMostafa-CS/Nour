// lib/features/adhan/presentation/pages/adhan_reciter_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/adhan_bloc.dart';
import '../bloc/adhan_event.dart';
import '../bloc/adhan_state.dart';
import '../services/adhan_preview_player.dart';
import '../widgets/adhan_reciter_tile.dart';

class AdhanReciterPage extends StatefulWidget {
  final String prayerName;
  final String prayerTitle;

  const AdhanReciterPage({
    super.key,
    required this.prayerName,
    required this.prayerTitle,
  });

  @override
  State<AdhanReciterPage> createState() => _AdhanReciterPageState();
}

class _AdhanReciterPageState extends State<AdhanReciterPage> {
  final AdhanPreviewPlayer _previewPlayer = AdhanPreviewPlayer();

  String? _playingId;

  @override
  void initState() {
    super.initState();

    // لما الصوت يخلص تلقائي → رجّع الأيقونة لـ play
    _previewPlayer.onCompleted = () {
      if (!mounted) return;
      setState(() => _playingId = null);
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdhanBloc>().add(const LoadAdhanReciters());
    });
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview({
    required String id,
    required String assetPath,
  }) async {
    try {
      final started = await _previewPlayer.toggle(
        id: id,
        assetPath: assetPath,
      );

      if (!mounted) return;
      setState(() => _playingId = started ? id : null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingId = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تشغيل صوت الأذان',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B5B),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'صوت أذان ${widget.prayerTitle}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AdhanBloc, AdhanState>(
          listenWhen: (prev, curr) {
            // لو اتغير الاختيار → نوقف أي preview شغال
            if (prev is AdhanLoaded && curr is AdhanLoaded) {
              return prev.selectedReciterId != curr.selectedReciterId;
            }
            return false;
          },
          listener: (context, state) async {
            if (state is AdhanLoaded && _playingId != null) {
              await _previewPlayer.stop();
              if (!mounted) return;
              setState(() => _playingId = null);
            }
          },
          builder: (context, state) {
            if (state is AdhanLoading || state is AdhanInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdhanError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
              );
            }

            if (state is! AdhanLoaded) {
              return const SizedBox();
            }

            if (state.reciters.isEmpty) {
              return Center(
                child: Text(
                  'لا يوجد مؤذنون متاحون',
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.reciters.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final reciter = state.reciters[index];
                final isSelected = state.selectedReciterId == reciter.id;
                final isPlaying = _playingId == reciter.id;

                return AdhanReciterTile(
                  reciter: reciter,
                  isSelected: isSelected,
                  isPlaying: isPlaying,
                  onSelect: () {
                    context.read<AdhanBloc>().add(
                      SelectAdhanReciter(reciterId: reciter.id),
                    );
                  },
                  onTogglePreview: () => _togglePreview(
                    id: reciter.id,
                    assetPath: reciter.normalAdhanAssetPath,

                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}