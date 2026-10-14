import 'package:flutter/material.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';
import 'views/auth_page.dart';
import 'views/dashboard_page.dart';
import 'views/landing_page.dart';
import 'widgets/liquid_glass.dart';

void main() {
  runApp(const PnlCdcApp());
}

class PnlCdcApp extends StatefulWidget {
  const PnlCdcApp({super.key});

  @override
  State<PnlCdcApp> createState() => _PnlCdcAppState();
}

class _PnlCdcAppState extends State<PnlCdcApp> {
  final AppController _controller = AppController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'CDC / UPA. PKK Politeknik Negeri Lhokseumawe - PNL Job Fair 2026',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScaffold(),
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    Widget activeView;
    switch (controller.currentPage) {
      case AppPage.landing:
        activeView = const LandingPage();
        break;
      case AppPage.auth:
        activeView = const AuthPage();
        break;
      case AppPage.dashboard:
        activeView = const DashboardPage();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: AmbientLiquidBackdrop(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: activeView,
          ),
        ),
      ),
    );
  }
}
