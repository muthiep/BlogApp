// ignore: file_names
// ignore: file_names
// ignore: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Auth/api.dart';
import '../Auth/session.dart';
import '../Auth/theme.dart';
import '../widgets/cover_image_field.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;
  bool loadingCategories = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse(Api.categories));
      final body = jsonDecode(response.body);
      setState(() => categories = body['data'] ?? []);
    } catch (_) {
      // do nothing
    } finally {
      if (mounted) setState(() => loadingCategories = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategoryId == null) {
      _showMessage('Pilih kategori terlebih dahulu');
      return;
    }

    final imageUrl = _imageUrlController.text.trim();

    setState(() => submitting = true);
    try {
      final response = await http.post(
        Uri.parse(Api.posts),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Session.token}',
        },
        body: jsonEncode({
          'id_category': selectedCategoryId,
          'title': _titleController.text.trim(),
          'content': _contentController.text.trim(),
          'image_url': imageUrl.isNotEmpty ? imageUrl : null,
        }),
      );

      final body = jsonDecode(response.body);
      if (!mounted) return;
      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        _showMessage(body['message'] ?? 'Gagal membuat artikel');
      }
    } catch (e) {
      _showMessage('Gagal terhubung ke server: $e');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Tulis Artikel', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoverImageField(
                  controller: _imageUrlController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: appInputDecoration(label: 'Judul Artikel'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Judul wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                loadingCategories
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            hint: const Text('Pilih Kategori'),
                            value: selectedCategoryId,
                            items: categories
                                .map<DropdownMenuItem<int>>(
                                  (category) => DropdownMenuItem<int>(
                                    value: category['id_category'],
                                    child: Text(category['name_category']),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => selectedCategoryId = value),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 10,
                  decoration: appInputDecoration(label: 'Isi Artikel'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Isi artikel wajib diisi' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Terbitkan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
