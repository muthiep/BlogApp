import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Auth/api.dart';
import '../Auth/format.dart';
import '../Auth/session.dart';
import '../Auth/theme.dart';
import 'edit_post.dart';

/// Halaman detail artikel. Tampilan mengikuti referensi (tombol kembali,
/// gambar/hero besar di atas, meta tanggal, judul, isi artikel).
/// Data diambil dari GET /api/posts/:id. Cover memakai image_url dari API.
class DetailPage extends StatefulWidget {
  final int postId;

  const DetailPage({super.key, required this.postId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? post;
  bool loading = true;
  // liked & saved hanya toggle tampilan lokal (bukan fitur backend), sama
  // seperti bookmark di versi sebelumnya — backend belum punya endpoint-nya.
  bool liked = false;
  bool saved = false;
  bool get isOwner => post != null && Session.idUser == post!['id_user'];
  bool get canEdit => isOwner; // bisa edit jika pemilik artikel
  bool get canDelete => isOwner; // bisa hapus jika pemilik artikel

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(Api.postById(widget.postId)));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() => post = body['data']);
      } else {
        _showMessage(body['message'] ?? 'Artikel tidak ditemukan');
      }
    } catch (e) {
      _showMessage('Gagal memuat artikel: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse(Api.postById(widget.postId)),
        headers: {'Authorization': 'Bearer ${Session.token}'},
      );
      final body = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showMessage(body['message'] ?? 'Gagal menghapus artikel');
      }
    } catch (e) {
      _showMessage('Gagal menghapus artikel: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = post != null && Session.idUser == post!['id_user'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : post == null
          ? const Center(child: Text('Artikel tidak ditemukan'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: 230,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _RoundIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _RoundIconButton(
                        icon: liked ? Icons.favorite : Icons.favorite_border,
                        onTap: () => setState(() => liked = !liked),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _RoundIconButton(
                        icon: Icons.mode_comment_outlined,
                        onTap: () =>
                            _showMessage('Fitur komentar belum tersedia'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 12),
                      child: _RoundIconButton(
                        icon: saved ? Icons.bookmark : Icons.bookmark_border,
                        onTap: () => setState(() => saved = !saved),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: (() {
                      final imageUrl = getPostImageUrl(post);
                      if (imageUrl == null) {
                        return Container(
                          color: AppColors.chipBackground,
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 40),
                          ),
                        );
                      }

                      return Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: AppColors.chipBackground,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      );
                    })(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -20, 0),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post!['category_name'] ?? '-',
                            style: AppTextStyles.meta.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                initialsOf(post!['author_name']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post!['author_name'] ?? '-',
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('•', style: AppTextStyles.meta),
                            const SizedBox(width: 6),
                            Text(
                              '${estimateReadMinutes(post!['content']?.toString())} min read',
                              style: AppTextStyles.meta,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          post!['title'] ?? '-',
                          style: AppTextStyles.heading.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(post!['created_at']),
                          style: AppTextStyles.meta,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 40,
                          height: 3,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        _DropCapBody(text: post!['content'] ?? ''),
                        if (isOwner) ...[
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditPostPage(post: post!),
                                      ),
                                    ).then((_) => _loadPost());
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                  onPressed: _deletePost,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Hapus'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// Menampilkan isi artikel dengan huruf pertama diperbesar (drop cap),
/// meniru gaya Medium. Dibuat dengan RichText/TextSpan biasa (materi Text
/// Widget), bukan package tambahan.
class _DropCapBody extends StatelessWidget {
  final String text;

  const _DropCapBody({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final firstLetter = text.substring(0, 1);
    final rest = text.substring(1);

    return RichText(
      text: TextSpan(
        style: AppTextStyles.body,
        children: [
          TextSpan(
            text: firstLetter,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          TextSpan(text: rest),
        ],
      ),
    );
  }
}
