import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    builder: (context, child) {
        return MaterialApp(
        title: 'Islamic App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.splashScreen,
          onGenerateInitialRoutes: (String initialRouteName) {
          return [
            AppRouter.onGenerateRoute(
              RouteSettings(name: initialRouteName),
            ),
          ];
        },
      );}
    );
  }
}