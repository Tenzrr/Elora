import 'package:flutter/material.dart';

/// Corner reticle guidelines overlay for the camera viewfinder.
/// Matches docs/screens/Scan camera.png specifications.
class ViewfinderReticle extends StatelessWidget {
  const ViewfinderReticle({
    super.key,
    this.boxSize = 280.0,
    this.cornerLength = 36.0,
    this.strokeWidth = 3.5,
  });

  final double boxSize;
  final double cornerLength;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: CustomPaint(
          painter: _ReticlePainter(
            cornerLength: cornerLength,
            strokeWidth: strokeWidth,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter({
    required this.cornerLength,
    required this.strokeWidth,
    required this.color,
  });

  final double cornerLength;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // Top-Left corner
    canvas.drawLine(Offset(0, 0), Offset(cl, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cl), paint);

    // Top-Right corner
    canvas.drawLine(Offset(w, 0), Offset(w - cl, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, h), Offset(cl, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cl), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(w, h), Offset(w - cl, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cl), paint);
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.color != color;
}
