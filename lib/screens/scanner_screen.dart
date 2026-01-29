import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/shadcn_ui.dart';
import '../providers/theme_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String? _scanResult;
  MobileScannerController? _mobileController;
  bool _isUrl = false;
  String? _faviconUrl;

  bool _isValidUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  String _getFaviconUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
    } catch (e) {
      return '';
    }
  }

  void _updateScanResult(String result) {
    setState(() {
      _scanResult = result;
      _isUrl = _isValidUrl(result);
      if (_isUrl) {
        _faviconUrl = _getFaviconUrl(result);
        debugPrint('🌐 Scanner: URL detected = $result');
        debugPrint('🌐 Scanner: Favicon URL = $_faviconUrl');
      } else {
        _faviconUrl = null;
        debugPrint('📝 Scanner: Text detected = $result');
      }
    });
  }

  Future<void> _copyToClipboard() async {
    if (_scanResult != null) {
      await Clipboard.setData(ClipboardData(text: _scanResult!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      debugPrint('📋 Scanner: Copied to clipboard');
    }
  }

  Future<void> _openUrl() async {
    if (_scanResult != null && _isUrl) {
      try {
        final uri = Uri.parse(_scanResult!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          debugPrint('🌐 Scanner: Opened URL = $_scanResult');
        } else {
          debugPrint('❌ Scanner: Cannot launch URL = $_scanResult');
        }
      } catch (e) {
        debugPrint('❌ Scanner: Error opening URL = $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 Scanner: initState called');
    _mobileController = MobileScannerController();
    debugPrint('🔍 Scanner: MobileScannerController created');
  }

  @override
  void dispose() {
    debugPrint('🔍 Scanner: dispose called');
    _mobileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 Scanner: build called');
    final theme = Provider.of<ThemeProvider>(context);
    debugPrint('🎨 Scanner: _scanResult = $_scanResult');

    // Mobile / Web Camera Scanner
    debugPrint('🎨 Scanner: Rendering mobile/web UI');
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scanner',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: theme.foreground,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera View - Only visible in scan area
          ClipPath(
            clipper: ScannerClipper(),
            child: MobileScanner(
              controller: _mobileController,
              onDetect: (capture) {
                debugPrint('📷 Scanner: onDetect called');
                final List<Barcode> barcodes = capture.barcodes;
                debugPrint('📷 Scanner: Barcodes found = ${barcodes.length}');

                if (barcodes.isNotEmpty) {
                  final code = barcodes.first.rawValue;
                  debugPrint('📷 Scanner: First barcode = $code');

                  if (code != null) {
                    debugPrint('✅ Scanner: QR code detected from camera!');
                    _updateScanResult(code);
                  } else {
                    debugPrint('⚠️ Scanner: Barcode rawValue is null');
                  }
                } else {
                  debugPrint('⚠️ Scanner: No barcodes in capture');
                }
              },
            ),
          ),

          // Background overlay (everything except scan area)
          if (_scanResult == null)
            CustomPaint(
              painter: ScannerOverlayPainter(
                borderColor: theme.primary,
                backgroundColor: theme.background.withValues(alpha: 0.9),
              ),
              child: Container(),
            ),

          // Animated scanning line
          if (_scanResult == null)
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: _AnimatedScanLine(color: theme.primary),
              ),
            ),

          // Corner decorations
          if (_scanResult == null)
            Center(
              child: Container(
                width: 280,
                height: 280,
                child: Stack(
                  children: [
                    // Top-left corner
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: theme.primary, width: 4),
                            left: BorderSide(color: theme.primary, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Top-right corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: theme.primary, width: 4),
                            right: BorderSide(color: theme.primary, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Bottom-left corner
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.primary, width: 4),
                            left: BorderSide(color: theme.primary, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    // Bottom-right corner
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.primary, width: 4),
                            right: BorderSide(color: theme.primary, width: 4),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions text
          if (_scanResult == null)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Text(
                "Align QR code within frame",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: theme.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Result Sheet
          if (_scanResult != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Scanned!",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.foreground,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _scanResult = null;
                              _isUrl = false;
                              _faviconUrl = null;
                            });
                            _mobileController?.start();
                          },
                          icon: Icon(Icons.close, color: theme.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Favicon and URL/Text display
                    if (_isUrl && _faviconUrl != null)
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.muted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _faviconUrl!,
                                width: 48,
                                height: 48,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.language,
                                    color: theme.primary,
                                    size: 28,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Website Link',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: theme.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Uri.parse(_scanResult!).host,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: theme.foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    if (_isUrl && _faviconUrl != null)
                      const SizedBox(height: 16),

                    // Result text box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.border),
                      ),
                      child: SelectableText(
                        _scanResult!,
                        style: GoogleFonts.inter(
                          color: theme.foreground,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ShadcnButton(
                            text: "Copy",
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: _copyToClipboard,
                            outline: true,
                          ),
                        ),
                        if (_isUrl) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ShadcnButton(
                              text: "Open",
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: _openUrl,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    ShadcnButton(
                      text: "Scan Again",
                      fullWidth: true,
                      ghost: true,
                      onPressed: () {
                        setState(() {
                          _scanResult = null;
                          _isUrl = false;
                          _faviconUrl = null;
                        });
                        _mobileController?.start();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom clipper for scanner area
class ScannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scanSize = 280.0;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;

    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanSize, scanSize),
        const Radius.circular(20),
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for overlay
class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scanSize = 280.0;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;

    // Draw background
    final bgPaint = Paint()..color = backgroundColor;
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanSize, scanSize),
          const Radius.circular(20),
        ),
      );

    final path = Path.combine(PathOperation.difference, bgPath, holePath);
    canvas.drawPath(path, bgPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Animated scan line painter
class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final y = size.height * progress;
    canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), paint);

    // Gradient effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40));

    canvas.drawRect(
      Rect.fromLTWH(20, y - 20, size.width - 40, 40),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Animated scan line widget
class _AnimatedScanLine extends StatefulWidget {
  final Color color;

  const _AnimatedScanLine({required this.color});

  @override
  State<_AnimatedScanLine> createState() => _AnimatedScanLineState();
}

class _AnimatedScanLineState extends State<_AnimatedScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanLinePainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}
