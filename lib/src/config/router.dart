import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/symptom_checker_screen.dart';
import '../presentation/screens/image_uploader_screen.dart';
import '../presentation/screens/lab_analysis_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/symptom_checker',
          builder: (context, state) => const SymptomCheckerScreen(),
        ),
        GoRoute(
          path: '/image_uploader',
          builder: (context, state) => const ImageUploaderScreen(),
        ),
        GoRoute(
          path: '/lab_analysis',
          builder: (context, state) => const LabAnalysisScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Symptoms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Image Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Lab Reports',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/symptom_checker')) {
      return 1;
    }
    if (location.startsWith('/image_uploader')) {
      return 2;
    }
    if (location.startsWith('/lab_analysis')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/symptom_checker');
        break;
      case 2:
        GoRouter.of(context).go('/image_uploader');
        break;
      case 3:
        GoRouter.of(context).go('/lab_analysis');
        break;
    }
  }
}
