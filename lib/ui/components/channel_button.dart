import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';

class ChannelButton extends StatelessWidget {
  const ChannelButton({super.key, required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 74.adaptedWidth,
        minHeight: 32.adaptedHeight,
      ),
      child: TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.adaptedRadius)),
              side: const BorderSide(color: Color(0xFFEDEDF5))),
          backgroundColor: Colors.white,
        ),
        label: Text(text,
            style: TextStyle(fontSize: 12.adaptedFontSize, color: Colors.black)),
        icon: Container(
          width: 15.adaptedWidth,
          height: 15.adaptedHeight,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
