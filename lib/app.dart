import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splashScreen,

      // ⬇️ ده اللي بيمنع فلاتر من بناء مسار "/" الجذري تلقائيًا
      onGenerateInitialRoutes: (String initialRouteName) {
        return [
          AppRouter.onGenerateRoute(
            RouteSettings(name: initialRouteName),
          ),
        ];
      },
    );
  }
}