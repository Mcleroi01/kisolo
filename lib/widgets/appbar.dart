import 'package:flutter/material.dart';
import 'package:kisolo/core/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? logoAssetPath;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actionIcon,
    this.onActionPressed,
    this.logoAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (logoAssetPath != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                logoAssetPath!,
                height: 40,
              ),
            ),
          if (subtitle == null)
            Text(title)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: AppColors.accentOrange)),
                Text(subtitle!,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.primaryBlack)),
              ],
            ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentOrange,
                width: 3,
              ),
            ),
            child: Text(
              '1250 XP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
