import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/shadcn_ui.dart';
import '../providers/theme_provider.dart';
import 'generator_screen_web.dart'
    if (dart.library.io) 'generator_screen_stub.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = "https://ankesh.vercel.app";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _textController.text = _qrData;
  }

  Future<void> _saveQr(Color color) async {
    if (_qrData.isEmpty) return;

    setState(() {
      _saving = true;
    });

    try {
      final qrValidationResult = QrValidator.validate(
        data: _qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;

        final painter = QrPainter.withQr(
          qr: qrCode,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: color, // Use theme color
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: color, // Use theme color
          ),
          gapless: true,
        );

        // Create image with white background and padding
        final qrSize = 2048;
        final padding = 200;
        final totalSize = qrSize + (padding * 2);

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // Draw white background
        final bgPaint = Paint()..color = Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(0, 0, totalSize.toDouble(), totalSize.toDouble()),
          bgPaint,
        );

        // Draw QR code with padding
        canvas.save();
        canvas.translate(padding.toDouble(), padding.toDouble());
        painter.paint(canvas, Size(qrSize.toDouble(), qrSize.toDouble()));
        canvas.restore();

        final picture = recorder.endRecording();
        final img = await picture.toImage(totalSize, totalSize);
        final picData = await img.toByteData(format: ui.ImageByteFormat.png);
        if (picData == null) throw Exception("Failed to generate QR image");

        final pngBytes = picData.buffer.asUint8List();

        if (kIsWeb) {
          // Web: Direct download
          await downloadQrWeb(
            pngBytes,
            'g-enqr_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("✅ QR Code downloaded!"),
                backgroundColor: color,
              ),
            );
          }
        } else {
          // Mobile: Share QR code
          final directory = await getTemporaryDirectory();
          final fileName =
              'g-enqr_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(pngBytes);

          // Share the file
          await Share.shareXFiles([XFile(file.path)], text: 'QR Code');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("✅ Share QR Code"),
                backgroundColor: color,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Error saving QR code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    Color qrDotColor = theme.primary;
    Color qrBgColor = Colors.white;

    if (theme.isDarkMode) {
      qrBgColor = theme.card;
      if (qrBgColor == Colors.transparent) qrBgColor = Colors.black;
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // QR Display Card - Rounded Style Only
            Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: qrBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: qrDotColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: qrDotColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ShadcnCard(
              title: "Content",
              description: "Enter text or URL to generate QR code",
              child: Column(
                children: [
                  ShadcnInput(
                    controller: _textController,
                    placeholder: "https://ankesh.vercel.app",
                    onChanged: (val) {
                      setState(() {
                        _qrData = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ShadcnButton(
                    text: _saving
                        ? "Processing..."
                        : kIsWeb
                        ? "Download QR"
                        : "Share QR Code",
                    fullWidth: true,
                    icon: _saving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primaryForeground,
                            ),
                          )
                        : Icon(kIsWeb ? Icons.download : Icons.share, size: 18),
                    onPressed: _saving ? null : () => _saveQr(theme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
