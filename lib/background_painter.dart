import 'package:flutter/material.dart';
import 'dart:math';

class BackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  BackgroundPainter({this.isDarkMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Create gradient background based on theme
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode 
        ? [
            Color(0xFF0F172A), // Dark blue for dark mode
            Color(0xFF1E293B), // Medium blue for dark mode
            Color(0xFF334155), // Light blue for dark mode
          ]
        : [
            Color(0xFF1E3A8A), // Dark blue
            Color(0xFF2563EB), // Medium blue
            Color(0xFF3B82F6), // Light blue
          ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw cloud patterns
    _drawClouds(canvas, size);

    // Draw airplanes
    _drawAirplanes(canvas, size);

    // Draw buildings
    _drawBuildings(canvas, size);

    // Draw runway
    _drawRunway(canvas, size);

    // Draw stars
    _drawStars(canvas, size);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw several cloud ellipses
    final clouds = [
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.15),
      Offset(size.width * 0.4, size.height * 0.08),
      Offset(size.width * 0.8, size.height * 0.12),
    ];

    for (final cloud in clouds) {
      canvas.drawOval(
        Rect.fromCenter(center: cloud, width: 120, height: 60),
        cloudPaint,
      );
    }
  }

  void _drawAirplanes(Canvas canvas, Size size) {
    final airplanePaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final airplanes = [
      {
        'x': size.width * 0.8,
        'y': size.height * 0.1,
        'size': 80.0,
        'angle': 15.0,
      },
      {
        'x': size.width * 0.2,
        'y': size.height * 0.15,
        'size': 60.0,
        'angle': -10.0,
      },
      {
        'x': size.width * 0.5,
        'y': size.height * 0.08,
        'size': 40.0,
        'angle': 5.0,
      },
      {
        'x': size.width * 0.7,
        'y': size.height * 0.2,
        'size': 30.0,
        'angle': -5.0,
      },
    ];

    for (final plane in airplanes) {
      canvas.save();
      canvas.translate(plane['x']!, plane['y']!);
      canvas.rotate(plane['angle']! * pi / 180);

      final path = Path();
      path.moveTo(-plane['size']! * 0.4, 0);
      path.lineTo(plane['size']! * 0.4, 0);
      path.lineTo(plane['size']! * 0.3, -plane['size']! * 0.1);
      path.lineTo(plane['size']! * 0.4, 0);
      path.lineTo(plane['size']! * 0.3, plane['size']! * 0.1);
      path.close();

      canvas.drawPath(path, airplanePaint);
      canvas.restore();
    }
  }

  void _drawBuildings(Canvas canvas, Size size) {
    final buildingPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final buildings = [
      {
        'x': size.width * 0.4,
        'y': size.height * 0.6,
        'width': 200.0,
        'height': 400.0,
      },
      {
        'x': size.width * 0.8,
        'y': size.height * 0.5,
        'width': 120.0,
        'height': 300.0,
      },
      {
        'x': size.width * 0.2,
        'y': size.height * 0.7,
        'width': 100.0,
        'height': 200.0,
      },
    ];

    for (final building in buildings) {
      final rect = Rect.fromLTWH(
        building['x']! - building['width']! / 2,
        building['y']!,
        building['width']!,
        building['height']!,
      );
      canvas.drawRect(rect, buildingPaint);

      // Draw windows
      final windowSize = 8.0;
      final windowSpacing = 20.0;
      final startX = building['x']! - building['width']! / 2 + 10;
      final startY = building['y']! + 20;

      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 3; col++) {
          final windowRect = Rect.fromLTWH(
            startX + col * windowSpacing,
            startY + row * windowSpacing,
            windowSize,
            windowSize,
          );
          canvas.drawRect(windowRect, windowPaint);
        }
      }
    }
  }

  void _drawRunway(Canvas canvas, Size size) {
    final runwayPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final runwayY = size.height * 0.75;
    final runwayWidth = size.width * 0.6;
    final runwayX = (size.width - runwayWidth) / 2;

    // Draw runway lines
    for (int i = 0; i < 4; i++) {
      final lineRect = Rect.fromLTWH(runwayX, runwayY + i * 20, runwayWidth, 4);
      canvas.drawRect(lineRect, runwayPaint);
    }

    // Draw runway markings
    final markingRect1 = Rect.fromLTWH(runwayX, runwayY - 10, 50, 8);
    final markingRect2 = Rect.fromLTWH(
      runwayX + runwayWidth - 50,
      runwayY - 10,
      50,
      8,
    );
    canvas.drawRect(markingRect1, runwayPaint);
    canvas.drawRect(markingRect2, runwayPaint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final stars = [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.08),
      Offset(size.width * 0.45, size.height * 0.12),
      Offset(size.width * 0.6, size.height * 0.06),
      Offset(size.width * 0.75, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.08),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1, starPaint);
    }

    // Draw moon
    final moonPaint = Paint()
      ..color = (isDarkMode ? Colors.grey[300] : Colors.white)!.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.08),
      25,
      moonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
