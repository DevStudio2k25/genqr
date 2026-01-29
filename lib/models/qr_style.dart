import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum QrStyleType { classic, rounded, dots, sharp, gradient }

class QrStyle {
  final String name;
  final String description;
  final IconData icon;
  final QrStyleType type;

  const QrStyle({
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
  });

  static const List<QrStyle> allStyles = [
    QrStyle(
      name: 'Classic',
      description: 'Traditional square blocks',
      icon: Icons.grid_on,
      type: QrStyleType.classic,
    ),
    QrStyle(
      name: 'Rounded',
      description: 'Smooth rounded corners',
      icon: Icons.rounded_corner,
      type: QrStyleType.rounded,
    ),
    QrStyle(
      name: 'Dots',
      description: 'Circular dot pattern',
      icon: Icons.circle,
      type: QrStyleType.dots,
    ),
    QrStyle(
      name: 'Sharp',
      description: 'Extra sharp edges',
      icon: Icons.change_history,
      type: QrStyleType.sharp,
    ),
    QrStyle(
      name: 'Gradient',
      description: 'Colorful gradient style',
      icon: Icons.gradient,
      type: QrStyleType.gradient,
    ),
  ];

  QrEyeShape getEyeShape() {
    switch (type) {
      case QrStyleType.classic:
        return QrEyeShape.square;
      case QrStyleType.rounded:
        return QrEyeShape.circle;
      case QrStyleType.dots:
        return QrEyeShape.circle;
      case QrStyleType.sharp:
        return QrEyeShape.square;
      case QrStyleType.gradient:
        return QrEyeShape.circle;
    }
  }

  QrDataModuleShape getDataModuleShape() {
    switch (type) {
      case QrStyleType.classic:
        return QrDataModuleShape.square;
      case QrStyleType.rounded:
        return QrDataModuleShape.circle;
      case QrStyleType.dots:
        return QrDataModuleShape.circle;
      case QrStyleType.sharp:
        return QrDataModuleShape.square;
      case QrStyleType.gradient:
        return QrDataModuleShape.circle;
    }
  }

  bool get hasGradient => type == QrStyleType.gradient;
}
