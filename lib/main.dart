import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide system UI overlays (status bar and navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        size: Size(350, 700), // Mobile ratio
        // essential to fix size
        minimumSize: Size(350, 700),
        maximumSize: Size(350, 700),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden, // Hides system bar
        title: "GenQR",
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setResizable(false); // Fix size
        await windowManager.setMaximizable(false); // No fullscreen
        await windowManager.setHasShadow(
          false,
        ); // Remove system shadow/border "line"
        await windowManager
            .setAsFrameless(); // <--- This removes the native OS border completely
        await windowManager.setBackgroundColor(
          Colors.transparent,
        ); // Ensure transparency
      });
    }
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
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeProvider.muted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: themeProvider.border,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "💡 Tip",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: themeProvider.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "For desktop, please download the Windows/Mac/Linux app instead.",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: themeProvider.mutedForeground,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
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

              // Permanent Padding for Desktop "Screen" feel + Custom Title Bar
              if (!kIsWeb &&
                  (Platform.isWindows ||
                      Platform.isLinux ||
                      Platform.isMacOS)) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: themeProvider.background, // Match app theme
                          child: Column(
                            children: [
                              // Integrated Title Bar
                              Container(
                                height: 32,
                                color: themeProvider.muted.withValues(
                                  alpha: 0.5,
                                ), // Slight contrast
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    // Drag Area & Title
                                    Expanded(
                                      child: DragToMoveArea(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "GenQR",
                                            style: GoogleFonts.inter(
                                              color: themeProvider.foreground,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Minimize
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async =>
                                            await windowManager.minimize(),
                                        hoverColor: themeProvider.muted,
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: Icon(
                                            Icons.remove,
                                            size: 14,
                                            color: themeProvider.foreground,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Close
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async =>
                                            await windowManager.close(),
                                        hoverColor: Colors.red,
                                        splashColor: Colors.redAccent,
                                        child: SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: themeProvider.foreground,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // App Content, ensure we don't have double Scaffolds issues if child has one
                              Expanded(child: child!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return child!;
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
