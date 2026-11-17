import 'package:flutter/material.dart';

import 'core/constants/app_name.dart';
import 'core/theme/app_theme.dart';
import 'view/timeline_view.dart';

class StarWarsApp extends StatelessWidget {
  const StarWarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const TimelineView(),
    );
  }
}