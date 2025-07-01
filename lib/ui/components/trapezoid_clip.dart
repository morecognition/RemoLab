import 'package:flutter/cupertino.dart';

class TrapezoidClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(size.width, 0.0);
    path.lineTo((size.width - 10) / 2.0, size.height);
    path.lineTo(1 - ((size.width - 10) / 2.0), size.height);
    path.lineTo(0.0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}