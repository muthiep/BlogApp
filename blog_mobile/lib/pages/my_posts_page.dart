import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Auth/api.dart';
import '../Auth/format.dart';
import '../Auth/session.dart';
import '../Auth/theme.dart';
import '../widgets/article_card.dart';
import 'detail.dart';

/// Menampilkan artikel milik user yang sedang login. Karena backend tidak
/// punya endpoint khusus "artikel saya", data diambil dari GET /api/posts
/// lalu difilter di sisi aplikasi berdasarkan id_user (sesuai fitur yang
/// memang tersedia).
class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List myPosts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(Api.posts));
      final body = jsonDecode(response.body);
      final all = (body['data'] ?? []) as List;
      setState(() {
        myPosts = all.where((post) => post['id_user'] == Session.idUser).toList();
      });
    } catch (_) {
      // biarkan list kosong jika gagal, cukup tampilkan state kosong
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
        children: [
          const Text('Tulisan Saya', style: AppTextStyles.heading),
          const SizedBox(height: 18),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (myPosts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('Kamu belum menulis artikel apapun', style: AppTextStyles.meta),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPosts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.chipBackground),
              itemBuilder: (context, index) {
                final post = myPosts[index];
                return ArticleCard(
                  postId: post['id_post'] ?? 0,
                  title: post['title'] ?? '-',
                  authorName: post['author_name'] ?? '-',
                  dateText: formatDate(post['created_at']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailPage(postId: post['id_post'])),
                    ).then((_) => _load());
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
