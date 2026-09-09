import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/router/app_router.dart';
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
                image: 'assets/images/quran.png',
                title: 'القرآن الكريم',
                subtitle: 'آخر قراءة',

              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: FeatureCard(
                image: 'assets/images/mosque_design_no_frame.png',
                title: 'الأذكار',
                subtitle: 'حصن المسلم',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

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
                title: 'التقويم الهجري',
                subtitle:getCurrentHijriDate(),
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFF333333),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: FeatureCard(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRouter.qibla,
                  );
                },
                title: 'اتجاه القبلة',
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
