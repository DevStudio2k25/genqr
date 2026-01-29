import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outline;
  final bool ghost;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const ShadcnButton({
    super.key,
    required this.text,
    this.onPressed,
    this.outline = false,
    this.ghost = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    Color bg = theme.primary;
    Color fg = theme.primaryForeground;
    Border? border;

    if (outline) {
      bg = Colors.transparent;
      fg = theme.foreground;
      border = Border.all(color: theme.border);
    } else if (ghost) {
      bg = Colors.transparent;
      fg = theme.foreground;
      border = null;
    } else {
      if (backgroundColor != null) bg = backgroundColor!;
      if (textColor != null) fg = textColor!;
    }

    // Ghost hover effect logic is usually handled by ButtonStyle's overlay color,
    // but here we are using a raw container for specific styling.
    // We'll use ElevatedButton with custom style to get ample hit test and a11y.

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 40, // h-10
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg, // Icon/Text color
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // radius-md
            side: border != null
                ? BorderSide(color: theme.border)
                : BorderSide.none,
          ),
          overlayColor: theme.secondary, // Hover effect
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShadcnInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const ShadcnInput({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(color: Colors.transparent),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontSize: 14, color: theme.foreground),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: theme.mutedForeground,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: theme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: theme.ring, width: 2), // Ring effect
          ),
        ),
      ),
    );
  }
}

class ShadcnCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? description;
  final Widget? footer;

  const ShadcnCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bool isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    final double cardPadding = isDesktop ? 16 : 24;
    final double titleSize = isDesktop ? 18 : 24;
    final double descSize = isDesktop ? 12 : 14;

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || description != null)
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.inter(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        color: theme.cardForeground,
                      ),
                    ),
                  if (description != null) ...[
                    SizedBox(height: isDesktop ? 4 : 6),
                    Text(
                      description!,
                      style: GoogleFonts.inter(
                        fontSize: descSize,
                        color: theme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              cardPadding,
              (title != null) ? 0 : cardPadding,
              cardPadding,
              cardPadding,
            ),
            child: child,
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                cardPadding,
                0,
                cardPadding,
                cardPadding,
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}
