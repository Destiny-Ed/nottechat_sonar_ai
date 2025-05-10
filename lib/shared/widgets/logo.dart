// lib/widgets/nottechat_logo.dart
import 'package:flutter/material.dart';

class NotteChatLogo extends StatelessWidget {
  final double size;
  final bool withText;

  NotteChatLogo({this.size = 100, this.withText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Crescent Moon
              CustomPaint(size: Size(size * 0.8, size * 0.8), painter: CrescentMoonPainter()),
              // Speech Bubble
              Positioned(
                bottom: 0,
                right: 0,
                child: CustomPaint(size: Size(size * 0.5, size * 0.5), painter: SpeechBubblePainter()),
              ),
            ],
          ),
        ),
        if (withText) ...[
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Notte', style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(
                'Chat',
                style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.bold, color: Color(0xFF00ACC1)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(0xFF1A237E)
          ..style = PaintingStyle.fill;
    final path =
        Path()
          ..moveTo(size.width * 0.5, 0)
          ..quadraticBezierTo(size.width, size.height * 0.25, size.width * 0.5, size.height * 0.5)
          ..quadraticBezierTo(0, size.height * 0.75, size.width * 0.5, size.height)
          ..quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width * 0.5, size.height * 0.5)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Color(0xFF00ACC1)
          ..style = PaintingStyle.fill;
    final path =
        Path()
          ..moveTo(size.width * 0.1, 0)
          ..lineTo(size.width * 0.9, 0)
          ..quadraticBezierTo(size.width, size.height * 0.3, size.width, size.height * 0.7)
          ..lineTo(size.width * 0.7, size.height * 0.7)
          ..lineTo(size.width * 0.5, size.height) // Tail
          ..lineTo(size.width * 0.3, size.height * 0.7)
          ..quadraticBezierTo(0, size.height * 0.3, size.width * 0.1, 0)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
