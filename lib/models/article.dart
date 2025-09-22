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
  final List<int> photos;
  final List<ArticleFileLink> files;

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
      sellingPrice: _toDouble(json['selling_price']) ?? 0,
      multipleItems: _toBool(json['multiple_items']),
      stock: _parseInt(json['stock']),
      newSellingPrice: _toDouble(json['new_selling_price']),
      description: json['description'] as String?,
      photos:
          (json['photos'] as List?)
              ?.map((e) => _parseInt(e))
              .whereType<int>()
              .toList() ??
          const [],
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
      'selling_price': sellingPrice,
      'multiple_items': multipleItems,
      'stock': stock,
      'new_selling_price': newSellingPrice,
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
    List<int>? photos,
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

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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
    return ArticleFileLink(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      articleId: json['articles_id'] as String,
      fileId: json['directus_files_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'articles_id': articleId, 'directus_files_id': fileId};
  }
}
