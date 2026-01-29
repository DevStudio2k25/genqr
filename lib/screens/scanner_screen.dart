import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/zxing.dart';
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

  bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 Scanner: initState called');
    debugPrint('🔍 Scanner: isDesktop = $isDesktop');
    _mobileController = MobileScannerController();
    debugPrint('🔍 Scanner: MobileScannerController created');
  }

  @override
  void dispose() {
    debugPrint('🔍 Scanner: dispose called');
    _mobileController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    debugPrint('📸 Scanner: _pickImage called');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    debugPrint('📸 Scanner: FilePicker result = ${result?.files.single.path}');

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      debugPrint('📸 Scanner: Image path = $path');

      try {
        debugPrint('📸 Scanner: Reading image file...');
        final File imageFile = File(path);
        final bytes = await imageFile.readAsBytes();
        debugPrint('📸 Scanner: Image bytes length = ${bytes.length}');

        final image = img.decodeImage(bytes);
        debugPrint(
          '📸 Scanner: Image decoded, size = ${image?.width}x${image?.height}',
        );

        if (image == null) {
          debugPrint('❌ Scanner: Failed to decode image');
          setState(() {
            _scanResult = "Failed to decode image.";
          });
          return;
        }

        debugPrint('📸 Scanner: Converting to grayscale...');
        final width = image.width;
        final height = image.height;
        final pixels = <int>[];

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            final gray = (r + g + b) ~/ 3;
            pixels.add(gray);
          }
        }
        debugPrint(
          '📸 Scanner: Grayscale conversion complete, pixels = ${pixels.length}',
        );

        debugPrint('📸 Scanner: Creating luminance source...');
        final source = RGBLuminanceSource(width, height, pixels);
        final bitmap = BinaryBitmap(HybridBinarizer(source));
        debugPrint('📸 Scanner: BinaryBitmap created');

        try {
          debugPrint('📸 Scanner: Decoding QR code...');
          final reader = MultiFormatReader();
          final result = reader.decode(bitmap);
          debugPrint('✅ Scanner: QR code decoded successfully!');
          debugPrint('✅ Scanner: Result = ${result.text}');

          setState(() {
            _scanResult = result.text;
          });
        } catch (e) {
          debugPrint('❌ Scanner: No QR code found in image');
          debugPrint('❌ Scanner: Error = $e');
          setState(() {
            _scanResult = "No QR code found in image.";
          });
        }
      } catch (e) {
        debugPrint('❌ Scanner: Error processing image');
        debugPrint('❌ Scanner: Error = $e');
        setState(() {
          _scanResult = "Error: ${e.toString()}";
        });
      }
    } else {
      debugPrint('📸 Scanner: No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 Scanner: build called');
    final theme = Provider.of<ThemeProvider>(context);
    debugPrint('🎨 Scanner: isDesktop = $isDesktop');
    debugPrint('🎨 Scanner: _scanResult = $_scanResult');

    if (isDesktop) {
      debugPrint('🎨 Scanner: Rendering desktop UI');
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
            'Scanner',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: theme.foreground,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.border,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.image_search, size: 60, color: theme.primary),
                    const SizedBox(height: 16),
                    Text(
                      "Scan from Image",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select a QR code image from your computer to scan it.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShadcnButton(
                      text: "Select Image",
                      fullWidth: true,
                      icon: const Icon(Icons.upload_file, size: 18),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),

              if (_scanResult != null) ...[
                const SizedBox(height: 20),
                ShadcnCard(
                  title: "Scan Result",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.muted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _scanResult!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: theme.foreground,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShadcnButton(
                        text: "Copy Result",
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          // Copy clipboard logic here if needed
                          // Clipboard.setData(ClipboardData(text: _scanResult!));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

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
                    setState(() {
                      _scanResult = code;
                    });
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
              bottom: 180,
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

          // Gallery button at bottom
          if (_scanResult == null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.photo_library,
                          color: theme.primaryForeground,
                          size: 28,
                        ),
                        onPressed: _pickImage,
                        iconSize: 60,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Pick from Gallery",
                      style: GoogleFonts.inter(
                        color: theme.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                            });
                            _mobileController?.start();
                          },
                          icon: Icon(Icons.close, color: theme.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _scanResult!,
                        style: GoogleFonts.inter(color: theme.foreground),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShadcnButton(
                      text: "Scan Again",
                      fullWidth: true,
                      onPressed: () {
                        setState(() {
                          _scanResult = null;
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
