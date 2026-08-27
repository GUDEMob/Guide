import 'package:flutter/material.dart';
import 'package:gude_app/core/router/app_router.dart';
import 'package:gude_app/core/theme/app_theme.dart';

class GudeApp extends StatelessWidget {
  const GudeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gude',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Constrain to phone width when running on desktop/tablet
        return LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 480;
          if (!isWide) return child!;
          return Scaffold(
            backgroundColor: const Color(0xFFE0E0E0),
            body: Center(
              child: Container(
                width: 390,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipRect(child: child!),
              ),
            ),
          );
        });
      },
    );
  }
}
