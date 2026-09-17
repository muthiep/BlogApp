import 'package:flutter/material.dart';
import '../Auth/format.dart';
import '../Auth/theme.dart';

/// Kartu artikel versi ringkas: tanpa cover, cukup judul dan nama penulis.
class ArticleCard extends StatelessWidget {
  final int postId;
  final String title;
  final String authorName;
  final String dateText;
  final String? description;
  final String? imageUrl;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.postId,
    required this.title,
    required this.authorName,
    required this.dateText,
    this.description,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = (description ?? '').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.meta.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initialsOf(authorName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: AppTextStyles.meta.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(dateText, style: AppTextStyles.meta),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
