import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.background),
      body: const Center(
        child: Text('Màn hình này sẽ có ở bước sau', style: TextStyle(color: AppColors.muted)),
      ),
    );
  }
}
