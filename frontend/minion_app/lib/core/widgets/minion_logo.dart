import 'package:flutter/material.dart';

/// Modern shield logo with gradient and "M" lettermark.
/// Gradient adapts to the current app theme.
class MinionLogo extends StatelessWidget {
  final double size;
  const MinionLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Derive two gradient colors from the theme
    final c1 = cs.primary;
    final c2 = cs.secondary;

    return SizedBox(
      width: size * 0.84,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(c1: c1, c2: c2),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.04),
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color c1;
  final Color c2;
  const _ShieldPainter({required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _buildPath(w, h);

    // Glow
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()
        ..color = c1.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Gradient fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [c1, c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Highlight
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.center,
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5)),
    );
  }

  Path _buildPath(double w, double h) {
    final r = w * 0.22;
    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, h * 0.54);
    path.cubicTo(w, h * 0.79, w * 0.66, h * 0.91, w * 0.5, h);
    path.cubicTo(w * 0.34, h * 0.91, 0, h * 0.79, 0, h * 0.54);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) =>
      old.c1 != c1 || old.c2 != c2;
}
