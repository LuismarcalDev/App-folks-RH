import 'package:flutter/material.dart';

/// Avatar de Perfil Profissional e Simples
class ProfileAvatar extends StatelessWidget {
  final double size;
  final IconData? icon;
  final String? initials;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final double? borderRadius;

  const ProfileAvatar({
    super.key,
    this.size = 32,
    this.icon,
    this.initials,
    this.backgroundColor = const Color(0xFF1B2A6B),
    this.borderColor = Colors.white,
    this.foregroundColor = Colors.white,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.22);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      alignment: Alignment.center,
      child: initials != null && initials!.isNotEmpty
          ? Text(
              initials!,
              style: TextStyle(
                color: foregroundColor,
                fontSize: size * 0.40,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            )
          : Icon(
              icon ?? Icons.person,
              color: foregroundColor,
              size: size * 0.55,
            ),
    );
  }
}

/// Versão profissional e simples para avatar de usuário
class AlienAvatar extends StatelessWidget {
  final double size;

  const AlienAvatar({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      size: size,
      icon: Icons.person_outline,
    );
  }
}

/// Versão profissional e simples para crachá de identificação
class SkullBadge extends StatelessWidget {
  final double size;

  const SkullBadge({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      size: size,
      icon: Icons.badge_outlined,
    );
  }
}

/// Double Chevron Up Icon (Red / Priority Indicator)
class DoubleChevronUp extends StatelessWidget {
  final Color color;
  final double size;

  const DoubleChevronUp({
    super.key,
    this.color = const Color(0xFFE57373),
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DoubleChevronPainter(color: color),
      ),
    );
  }
}

class _DoubleChevronPainter extends CustomPainter {
  final Color color;

  _DoubleChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Top chevron
    final pathTop = Path();
    pathTop.moveTo(0, h * 0.38);
    pathTop.lineTo(w * 0.5, 0.05 * h);
    pathTop.lineTo(w, h * 0.38);
    canvas.drawPath(pathTop, paint);

    // Bottom chevron
    final pathBottom = Path();
    pathBottom.moveTo(0, h * 0.85);
    pathBottom.lineTo(w * 0.5, 0.52 * h);
    pathBottom.lineTo(w, h * 0.85);
    canvas.drawPath(pathBottom, paint);
  }

  @override
  bool shouldRepaint(covariant _DoubleChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
