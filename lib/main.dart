import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'utils/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide system UI overlays (status bar and navigation bar) - Mobile only
  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GenQR',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              // Web: Show mobile-only message on desktop screens
              if (kIsWeb) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (ResponsiveHelper.isDesktopWeb(constraints.maxWidth)) {
                      // Desktop web - show restriction message
                      return Scaffold(
                        backgroundColor: themeProvider.background,
                        body: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  size: 80,
                                  color: themeProvider.primary,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  "Mobile Only",
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.foreground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "This web app is designed for mobile devices only.",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: themeProvider.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Please open this app on your phone or resize your browser window to mobile size (width < 768px).",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: themeProvider.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // Mobile web - show app
                    return child!;
                  },
                );
              }

              // Mobile - direct app
              return child!;
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
