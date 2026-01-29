import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
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
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.black,
          ),
          gapless: true,
        );

        final picData = await painter.toImageData(
          2048,
          format: ui.ImageByteFormat.png,
        );
        if (picData == null) throw Exception("Failed to generate QR image");

        final pngBytes = picData.buffer.asUint8List();

        if (kIsWeb) {
          // Web: Direct download
          await downloadQrWeb(
            pngBytes,
            'qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("✅ QR Code downloaded!"),
                backgroundColor: color,
              ),
            );
          }
        } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Desktop: Save File Dialog
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Save QR Code',
            fileName: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
            type: FileType.image,
            allowedExtensions: ['png'],
          );

          if (outputFile != null) {
            if (!outputFile.endsWith('.png')) outputFile += '.png';
            final file = File(outputFile);
            await file.writeAsBytes(pngBytes);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("✅ Saved successfully!"),
                  backgroundColor: color,
                ),
              );
            }
          }
        } else {
          // Mobile: Save to Downloads
          final directory = Platform.isAndroid
              ? Directory('/storage/emulated/0/Download')
              : await getApplicationDocumentsDirectory();

          final fileName =
              'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(pngBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✅ Saved to ${directory.path}/$fileName"),
                backgroundColor: color,
                duration: const Duration(seconds: 3),
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
    final bool isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    Color qrDotColor = theme.primary;
    Color qrBgColor = Colors.white;

    if (theme.isDarkMode) {
      qrBgColor = theme.card;
      if (qrBgColor == Colors.transparent) qrBgColor = Colors.black;
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: isDesktop ? 16 : 24),

            // QR Display Card - Rounded Style Only
            Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 16 : 24),
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
                    size: isDesktop ? 160.0 : 200.0,
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

            SizedBox(height: isDesktop ? 20 : 30),

            ShadcnCard(
              title: "Content",
              description: "Enter text or URL to generate QR code",
              child: Column(
                children: [
                  ShadcnInput(
                    controller: _textController,
                    placeholder: "https://example.com",
                    onChanged: (val) {
                      setState(() {
                        _qrData = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ShadcnButton(
                    text: _saving ? "Saving..." : "Save QR Code",
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
                        : const Icon(Icons.download, size: 18),
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
