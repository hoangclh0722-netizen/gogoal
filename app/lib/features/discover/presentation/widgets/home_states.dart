import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onCreate, this.onClear});

  final VoidCallback onCreate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BallAndPin(),
          const SizedBox(height: 20),
          const Text('Chưa có kèo nào gần bạn',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Thử đổi bộ lọc hoặc tạo kèo mới',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.muted)),
          const SizedBox(height: 24),
          AppButton(label: 'Tạo kèo', kind: AppButtonKind.accent, onPressed: onCreate),
          if (onClear != null) ...[
            const SizedBox(height: 12),
            AppButton(label: 'Xóa bộ lọc', kind: AppButtonKind.outline, onPressed: onClear),
          ],
        ],
      ),
    );
  }
}

class _BallAndPin extends StatelessWidget {
  const _BallAndPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          ),
          const Positioned(left: 8, bottom: 8, child: Icon(Icons.sports_soccer, size: 48, color: AppColors.primaryDark)),
          const Positioned(right: 10, top: 0, child: Icon(Icons.location_on_outlined, size: 52, color: AppColors.accent)),
        ],
      ),
    );
  }
}

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.muted),
          const SizedBox(height: 16),
          const Text('Không kết nối được',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Kiểm tra mạng rồi thử lại nhé',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.muted)),
          const SizedBox(height: 24),
          AppButton(label: 'Thử lại', kind: AppButtonKind.outline, expand: false, onPressed: onRetry),
        ],
      ),
    );
  }
}

class LocationBanner extends StatelessWidget {
  const LocationBanner({super.key, required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, size: 20, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Bật vị trí để xem kèo gần bạn',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF78350F))),
          ),
          TextButton(
            onPressed: onEnable,
            child: const Text('Bật vị trí',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
          ),
        ],
      ),
    );
  }
}
