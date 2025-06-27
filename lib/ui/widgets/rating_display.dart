import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double iconSize;
  final bool showTotal;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.iconSize = 16,
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final isHalf = index + 0.5 == rating;
            final isFilled = index < rating;

            return Icon(
              isHalf
                  ? Icons.star_half
                  : isFilled
                      ? Icons.star
                      : Icons.star_border,
              color: AppColors.warning,
              size: iconSize,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          showTotal
              ? '${rating.toStringAsFixed(1)}/5.0 ($totalReviews reviews)'
              : rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: iconSize - 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
