class Article {
  final String id;
  final String userCreated;
  final DateTime dateCreated;
  final String? userUpdated;
  final DateTime? dateUpdated;
  final String number;
  final String title;
  final double sellingPrice;
  final bool multipleItems;
  final int? stock;
  final double? newSellingPrice;
  final String? description;
  final List<String> photos;
  final List<ArticleFileLink> files;

  List<String> get assetFileIds {
    final relationIds = files
        .map((file) => file.fileId)
        .where((id) => id.isNotEmpty)
        .toList();
    final legacyPhotoIds = photos.map((id) => id.toString()).toList();
    final uniqueIds = <String>{...relationIds, ...legacyPhotoIds};
    return uniqueIds.toList();
  }

  const Article({
    required this.id,
    required this.userCreated,
    required this.dateCreated,
    required this.number,
    required this.title,
    required this.sellingPrice,
    required this.multipleItems,
    this.userUpdated,
    this.dateUpdated,
    this.stock,
    this.newSellingPrice,
    this.description,
    this.photos = const [],
    this.files = const [],
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      userCreated: json['user_created'] as String,
      dateCreated: DateTime.parse(json['date_created'] as String),
      userUpdated: json['user_updated'] as String?,
      dateUpdated: json['date_updated'] != null
          ? DateTime.parse(json['date_updated'] as String)
          : null,
      number: json['number']?.toString() ?? '',
      title: json['title'] as String,
      sellingPrice: _toCurrency(json['selling_price']) ?? 0,
      multipleItems: _toBool(json['multiple_items']),
      stock: _parseInt(json['stock']),
      newSellingPrice: _toCurrency(json['new_selling_price']),
      description: json['description'] as String?,
      photos: _parsePhotoIds(json['photos']),
      files:
          (json['articles_files'] as List?)
              ?.map((e) => ArticleFileLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_created': userCreated,
      'date_created': dateCreated.toIso8601String(),
      'user_updated': userUpdated,
      'date_updated': dateUpdated?.toIso8601String(),
      'number': number,
      'title': title,
      'selling_price': _fromCurrency(sellingPrice),
      'multiple_items': multipleItems,
      'stock': stock,
      'new_selling_price': newSellingPrice != null
          ? _fromCurrency(newSellingPrice!)
          : null,
      'description': description,
      'photos': photos,
      'articles_files': files.map((e) => e.toJson()).toList(),
    };
  }

  Article copyWith({
    String? id,
    String? userCreated,
    DateTime? dateCreated,
    String? userUpdated,
    DateTime? dateUpdated,
    String? number,
    String? title,
    double? sellingPrice,
    bool? multipleItems,
    int? stock,
    double? newSellingPrice,
    String? description,
    List<String>? photos,
    List<ArticleFileLink>? files,
  }) {
    return Article(
      id: id ?? this.id,
      userCreated: userCreated ?? this.userCreated,
      dateCreated: dateCreated ?? this.dateCreated,
      userUpdated: userUpdated ?? this.userUpdated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      number: number ?? this.number,
      title: title ?? this.title,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      multipleItems: multipleItems ?? this.multipleItems,
      stock: stock ?? this.stock,
      newSellingPrice: newSellingPrice ?? this.newSellingPrice,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      files: files ?? this.files,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final str = value.toString().toLowerCase();
    return str == 'true' || str == '1';
  }

  static List<String> _parsePhotoIds(dynamic value) {
    if (value is! List) {
      return const [];
    }

    final results = <String>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        final ref = item['directus_files_id'];
        if (ref is Map<String, dynamic>) {
          final id = ref['id'] ?? ref['file'];
          if (id != null && id.toString().isNotEmpty) {
            results.add(id.toString());
            continue;
          }
        }
        if (ref != null && ref.toString().isNotEmpty) {
          results.add(ref.toString());
          continue;
        }
        final fallback = item['id'] ?? item['file'];
        if (fallback != null && fallback.toString().isNotEmpty) {
          results.add(fallback.toString());
        }
      } else if (item != null && item.toString().isNotEmpty) {
        results.add(item.toString());
      }
    }

    return results;
  }

  static double? _toCurrency(dynamic value) {
    final cents = _toNum(value);
    if (cents == null) return null;
    return cents / 100;
  }

  static double? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _fromCurrency(double euros) {
    return (euros * 100).round();
  }
}

class ArticleFileLink {
  final int id;
  final String articleId;
  final String fileId;

  const ArticleFileLink({
    required this.id,
    required this.articleId,
    required this.fileId,
  });

  factory ArticleFileLink.fromJson(Map<String, dynamic> json) {
    final rawFileRef = json['directus_files_id'];
    final fileId = rawFileRef is Map<String, dynamic>
        ? (rawFileRef['id'] ?? rawFileRef['file'])?.toString() ?? ''
        : rawFileRef?.toString() ?? '';

    return ArticleFileLink(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      articleId: json['articles_id'] as String,
      fileId: fileId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'articles_id': articleId, 'directus_files_id': fileId};
  }
}
