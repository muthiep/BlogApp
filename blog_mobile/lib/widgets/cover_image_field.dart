import 'package:flutter/material.dart';
import '../Auth/theme.dart';

/// Input gambar sampul artikel bergaya Medium: kotak besar yang menampilkan
/// pratinjau gambar begitu URL diisi, memakai Image.network (materi Image
/// Widget) — bukan image_picker, supaya tetap sesuai widget yang sudah
/// dipelajari. Catatan: backend belum punya kolom gambar, jadi nilai ini
/// hanya dipakai untuk pratinjau di form dan tidak dikirim ke server.
class CoverImageField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CoverImageField({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.25)),
            ),
            child: controller.text.trim().isEmpty
                ? const _CoverPlaceholder()
                : Image.network(
                    controller.text.trim(),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, error, stackTrace) => const _CoverPlaceholder(
                      text: 'URL gambar tidak bisa dimuat',
                      icon: Icons.broken_image_outlined,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.url,
          onChanged: onChanged,
          decoration: appInputDecoration(
            label: 'URL Gambar Sampul (opsional)',
            hint: 'https://...',
            icon: Icons.link,
          ),
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final String text;
  final IconData icon;

  const _CoverPlaceholder({this.text = 'Tambah Gambar Sampul', this.icon = Icons.image_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: 8),
          Text(text, style: AppTextStyles.meta),
        ],
      ),
    );
  }
}
