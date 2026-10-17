import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/quran_bookmark_service.dart';
import '../../../quran/presentation/widgets/mushaf_page.dart';
import 'feature_card.dart';
import 'getCurrentHijriDate.dart';

class BuildMainGrid extends StatefulWidget {
  const BuildMainGrid({super.key});

  @override
  State<BuildMainGrid> createState() => _BuildMainGridState();
}

class _BuildMainGridState extends State<BuildMainGrid> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                onTap: () async {
                  final int? savedPage =
                  await QuranBookmarkService.getSavedPage();
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MushafPage(
                        startPage: savedPage ?? 1,
                      ),
                    ),
                  );
                },
                image: 'assets/images/quran.png',
                title: 'holy_quran'.tr(),
                subtitle: 'last_read'.tr(),
              ),
            ),
            SizedBox(width: 10.w),

            Expanded(
              child: FeatureCard(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRouter.tasbih,
                  );
                },
                image: 'assets/images/mosque_design_no_frame.png',
                title: 'electronic_tasbih'.tr(),
                subtitle: '',
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        Row(
          children: [
            Expanded(
              child: FeatureCard(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRouter.hijriCalendar,
                  );
                },
                title: 'hijri_calendar'.tr(),
                subtitle: getCurrentHijriDate(),
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFF333333),
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: FeatureCard(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRouter.qibla,
                  );
                },
                title: 'qibla_direction'.tr(),
                subtitle: '',
                icon: Icons.explore_outlined,
                iconColor: const Color(0xFF176B5B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}