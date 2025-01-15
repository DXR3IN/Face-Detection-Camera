import 'package:flutter/material.dart';

class BlockPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Overlay semi-transparan
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
          // Kotak transparan di tengah
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              child: CustomPaint(
                painter: CornerBorderPainter(),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.width * 0.4,
                    color: Colors.transparent,
                    shadows: const [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.1, 0)
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.9, 0)
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.1)
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.9)
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.9, size.height)
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.9)
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
