import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/shadcn_ui.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider;
    final bool isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: theme.foreground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isDesktop ? 16 : 24),

            ShadcnCard(
              title: "Appearance",
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dark Mode",
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 14 : 16,
                          color: theme.foreground,
                        ),
                      ),
                      Switch(
                        value: theme.isDarkMode,
                        onChanged: (val) {
                          theme.setThemeMode(
                            val ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        activeTrackColor: theme.primary,
                        activeThumbColor: theme.primaryForeground,
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 16 : 24),
                  Text(
                    "Theme Color",
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: theme.foreground,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 12),
                  Text(
                    "Select a color to customize your app theme",
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 12 : 13,
                      color: theme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 12 : 16),
                  Wrap(
                    spacing: isDesktop ? 10 : 12,
                    runSpacing: isDesktop ? 10 : 12,
                    alignment: WrapAlignment.center,
                    children: [
                      // Zinc/Slate (Default)
                      _buildColorOption(
                        theme,
                        const Color(0xFF18181B),
                        "Zinc",
                        isDesktop,
                      ),
                      // Red
                      _buildColorOption(
                        theme,
                        const Color(0xFFEF4444),
                        "Red",
                        isDesktop,
                      ),
                      // Rose
                      _buildColorOption(
                        theme,
                        const Color(0xFFF43F5E),
                        "Rose",
                        isDesktop,
                      ),
                      // Orange
                      _buildColorOption(
                        theme,
                        const Color(0xFFF97316),
                        "Orange",
                        isDesktop,
                      ),
                      // Amber
                      _buildColorOption(
                        theme,
                        const Color(0xFFF59E0B),
                        "Amber",
                        isDesktop,
                      ),
                      // Yellow
                      _buildColorOption(
                        theme,
                        const Color(0xFFEAB308),
                        "Yellow",
                        isDesktop,
                      ),
                      // Lime
                      _buildColorOption(
                        theme,
                        const Color(0xFF84CC16),
                        "Lime",
                        isDesktop,
                      ),
                      // Green
                      _buildColorOption(
                        theme,
                        const Color(0xFF22C55E),
                        "Green",
                        isDesktop,
                      ),
                      // Emerald
                      _buildColorOption(
                        theme,
                        const Color(0xFF10B981),
                        "Emerald",
                        isDesktop,
                      ),
                      // Teal
                      _buildColorOption(
                        theme,
                        const Color(0xFF14B8A6),
                        "Teal",
                        isDesktop,
                      ),
                      // Cyan
                      _buildColorOption(
                        theme,
                        const Color(0xFF06B6D4),
                        "Cyan",
                        isDesktop,
                      ),
                      // Sky
                      _buildColorOption(
                        theme,
                        const Color(0xFF0EA5E9),
                        "Sky",
                        isDesktop,
                      ),
                      // Blue
                      _buildColorOption(
                        theme,
                        const Color(0xFF3B82F6),
                        "Blue",
                        isDesktop,
                      ),
                      // Indigo
                      _buildColorOption(
                        theme,
                        const Color(0xFF6366F1),
                        "Indigo",
                        isDesktop,
                      ),
                      // Violet
                      _buildColorOption(
                        theme,
                        const Color(0xFF8B5CF6),
                        "Violet",
                        isDesktop,
                      ),
                      // Purple
                      _buildColorOption(
                        theme,
                        const Color(0xFFA855F7),
                        "Purple",
                        isDesktop,
                      ),
                      // Fuchsia
                      _buildColorOption(
                        theme,
                        const Color(0xFFD946EF),
                        "Fuchsia",
                        isDesktop,
                      ),
                      // Pink
                      _buildColorOption(
                        theme,
                        const Color(0xFFEC4899),
                        "Pink",
                        isDesktop,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    ThemeProvider theme,
    Color color,
    String name,
    bool isDesktop,
  ) {
    final isSelected = theme.primaryColor.value == color.value;
    final size = isDesktop ? 44.0 : 52.0;

    return GestureDetector(
      onTap: () => theme.setCustomPrimaryColor(color),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.foreground : theme.border,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: isDesktop ? 20 : 24,
                  )
                : null,
          ),
          SizedBox(height: isDesktop ? 4 : 6),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 10 : 11,
              color: isSelected ? theme.foreground : theme.mutedForeground,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
