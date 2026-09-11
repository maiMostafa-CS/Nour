import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import '../bloc/adhan_bloc.dart';
import '../bloc/adhan_event.dart';
import '../bloc/adhan_state.dart';

class AdhanReciterPage extends StatefulWidget {
  const AdhanReciterPage({
    super.key,
  });

  @override
  State<AdhanReciterPage> createState() =>
      _AdhanReciterPageState();
}

class _AdhanReciterPageState
    extends State<AdhanReciterPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _playingId;

  @override
  void initState() {
    super.initState();

    context.read<AdhanBloc>().add(
      const LoadAdhanReciters(),
    );
  }

  Future<void> _togglePreview(
      String id,
      String assetPath,
      ) async {
    try {
      if (_playingId == id) {
        await _audioPlayer.stop();

        if (mounted) {
          setState(() {
            _playingId = null;
          });
        }

        return;
      }

      await _audioPlayer.stop();

      await _audioPlayer.setAsset(
        assetPath,
      );

      if (!mounted) return;

      setState(() {
        _playingId = id;
      });

      await _audioPlayer.play();

      if (!mounted) return;

      setState(() {
        _playingId = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _playingId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تشغيل صوت الأذان',
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          'صوت الأذان',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<AdhanBloc, AdhanState>(
        builder: (context, state) {
          if (state is AdhanLoading ||
              state is AdhanInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AdhanError) {
            return Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is! AdhanLoaded) {
            return const SizedBox();
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: state.reciters.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final reciter =
              state.reciters[index];

              final isSelected =
                  state.selectedReciterId ==
                      reciter.id;

              final isPlaying =
                  _playingId == reciter.id;

              return InkWell(
                borderRadius:
                BorderRadius.circular(18.r),
                onTap: () {
                  context.read<AdhanBloc>().add(
                    SelectAdhanReciter(
                      reciter.id,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF176B5B)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        color: Colors.black
                            .withValues(alpha: 0.06),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFE8E8CE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          color:
                          const Color(0xFF176B5B),
                          size: 27.sp,
                        ),
                      ),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              reciter.name,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight:
                                FontWeight.bold,
                                color: const Color(
                                  0xFF176B5B,
                                ),
                              ),
                            ),

                            SizedBox(height: 5.h),

                            Text(
                              isSelected
                                  ? 'المؤذن الحالي'
                                  : 'اضغط للاختيار',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          _togglePreview(
                            reciter.id,
                            reciter.normalAdhanAssetPath,
                          );
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.stop_circle
                              : Icons.play_circle_fill,
                          size: 38.sp,
                          color:
                          const Color(0xFF176B5B),
                        ),
                      ),

                      SizedBox(width: 4.w),

                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color:
                          const Color(0xFF176B5B),
                          size: 27.sp,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey,
                          size: 27.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}