import 'package:flutter/cupertino.dart';

class TrapezoidClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var halfWidth = size.width / 2.0;
    var roundness = 10.0;
    var bottomOffset = 8.0;
    Path path = Path();
    path.moveTo(0.0, roundness);
    path.arcToPoint(Offset(roundness, 0.0), radius: Radius.circular(roundness));
    path.lineTo(size.width - roundness, 0.0);
    path.arcToPoint(Offset(size.width, roundness), radius: Radius.circular(roundness));
    path.lineTo(halfWidth + bottomOffset + roundness, size.height - roundness);
    path.arcToPoint(Offset(halfWidth + bottomOffset, size.height), radius: Radius.circular(roundness));
    path.lineTo(halfWidth - bottomOffset, size.height);
    path.arcToPoint(Offset(halfWidth - bottomOffset - roundness, size.height - roundness), radius: Radius.circular(roundness));
    path.lineTo(0.0, roundness);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}