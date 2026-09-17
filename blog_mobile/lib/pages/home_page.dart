import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Auth/api.dart';
import '../Auth/format.dart';
import '../Auth/session.dart';
import '../Auth/theme.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chip.dart';
import 'add_post.dart';
import 'detail.dart';
import 'login.dart';
import 'my_posts_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTab(),
      Session.isLoggedIn ? const MyPostsPage() : const _LoginRequiredTab(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: tabs[_tabIndex]),
      floatingActionButton: Session.isLoggedIn
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPostPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            label: 'Tulisan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class _LoginRequiredTab extends StatelessWidget {
  const _LoginRequiredTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Masuk untuk melihat tulisanmu',
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Masuk', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List posts = [];
  List categories = [];
  bool loading = true;
  String? error;
  String searchQuery = '';
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final results = await Future.wait([
        http.get(Uri.parse(Api.posts)),
        http.get(Uri.parse(Api.categories)),
      ]);

      final postsBody = jsonDecode(results[0].body);
      final categoriesBody = jsonDecode(results[1].body);

      setState(() {
        posts = postsBody['data'] ?? [];
        categories = categoriesBody['data'] ?? [];
      });
    } catch (_) {
      setState(() => error = 'Gagal memuat data. Periksa koneksi ke server.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List get _filteredPosts {
    return posts.where((post) {
      final matchesCategory =
          selectedCategoryId == null ||
          post['id_category'] == selectedCategoryId;
      final matchesSearch =
          searchQuery.isEmpty ||
          post['title'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredPosts;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Hi, ${Session.nameUser ?? 'Pembaca'}',
            style: AppTextStyles.meta.copyWith(
              color:const Color(0xFFE2B4BD),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selamat Membaca!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: appInputDecoration(
              label: '',
              hint: 'Cari judul artikel...',
              icon: Icons.search,
            ),
          ),
          const SizedBox(height: 22),
          if (categories.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryChip(
                    label: 'Semua',
                    selected: selectedCategoryId == null,
                    onTap: () => setState(() => selectedCategoryId = null),
                  ),
                  for (final category in categories)
                    CategoryChip(
                      label: category['name_category'],
                      selected: selectedCategoryId == category['id_category'],
                      onTap: () => setState(
                        () => selectedCategoryId = category['id_category'],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('${filtered.length} artikel', style: AppTextStyles.meta),
            ],
          ),
          const SizedBox(height: 6),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Belum ada artikel', style: AppTextStyles.meta),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.chipBackground),
              itemBuilder: (context, index) {
                final post = filtered[index];
                final contentRaw = (post['content'] ?? '').toString();
                final contentPreview = contentRaw
                    .replaceAll(RegExp(r'\s+'), ' ')
                    .trim();
                final previewText = contentPreview.length > 90
                    ? '${contentPreview.substring(0, 90)}...'
                    : contentPreview;

                return ArticleCard(
                  postId: post['id_post'] ?? 0,
                  title: post['title'] ?? '-',
                  authorName: post['author_name'] ?? '-',
                  dateText: formatDate(post['created_at']),
                  description: previewText,
                  imageUrl: getPostImageUrl(post),
                  onTap: () => _openDetail(post['id_post']),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(postId: id)),
    ).then((_) => _loadData());
  }
}
