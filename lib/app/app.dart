import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import 'routes/routes_application.dart';
import '../core/services/preferences_application_service.dart';

class StagiaApp extends StatelessWidget {
  const StagiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferencesApplicationService>.value(
      value: PreferencesApplicationService.instance,
      child: Consumer<PreferencesApplicationService>(
        builder: (context, preferences, _) => MaterialApp(
          title: 'STAGIA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: preferences.modeSombre ? ThemeMode.dark : ThemeMode.light,
          initialRoute: RoutesApplication.demarrage,
          onGenerateRoute: RoutesApplication.generer,
        ),
      ),
    );
  }
}
