String? getPostImageUrl(Map<String, dynamic>? post) {
  final imageUrl = post?['image_url'];

  if (imageUrl is String && imageUrl.trim().isNotEmpty) {
    return imageUrl.trim();
  }
  return null;
}

String formatDate(String? value) {
  if (value == null || value.isEmpty) return '-';
  try {
    final date = DateTime.parse(value);
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  } catch (_) {
    return value;
  }
}

int estimateReadMinutes(String? text) {
  if (text == null || text.isEmpty) return 1;

  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final minutes = (words / 200).ceil();
  return minutes < 1 ? 1 : minutes;
}

String initialsOf(String? value) {
  if (value == null || value.isEmpty) return '?';

  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
