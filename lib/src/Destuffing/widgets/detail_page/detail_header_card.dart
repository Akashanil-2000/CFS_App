import 'package:cfs_app/src/constants/theme.dart';
import 'package:flutter/material.dart';

class DetailHeaderCard extends StatelessWidget {
  final String title;
  final String customsStatus;
  final String paymentStatus;

  const DetailHeaderCard({
    super.key,
    required this.title,
    required this.customsStatus,
    required this.paymentStatus,
  });

  Widget statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.textDark.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CONTAINER NAME
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 12),

          /// STATUS CHIPS
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [statusChip(customsStatus), statusChip(paymentStatus)],
          ),
        ],
      ),
    );
  }
}
