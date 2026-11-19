import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Biểu tượng ghim sân + chữ GoGoal, dùng trên nền xanh.
class LogoWordmark extends StatelessWidget {
  const LogoWordmark({super.key, this.size = 22, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/brand/mark.svg', width: size * 1.4, height: size * 1.4),
        const SizedBox(width: 4),
        Text(
          'GoGoal',
          style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1),
        ),
      ],
    );
  }
}
