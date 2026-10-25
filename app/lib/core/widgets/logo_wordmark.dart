import 'package:flutter/material.dart';

class LogoWordmark extends StatelessWidget {
  const LogoWordmark({super.key, this.size = 22, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('G', style: style),
        Icon(Icons.sports_soccer, color: color, size: size * 0.95),
        Text('Goal', style: style),
      ],
    );
  }
}
