import 'package:cfs_app/src/constants/theme.dart';
import 'package:flutter/material.dart';

class DetailInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const DetailInfoRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value ?? "-",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
