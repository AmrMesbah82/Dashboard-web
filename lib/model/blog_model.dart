// ******************* FILE INFO *******************
// File Name: blog_model.dart
// Created by: Amr Mesbah

class BlogBilingualText {
  final String en;
  final String ar;
  const BlogBilingualText({this.en = '', this.ar = ''});

  factory BlogBilingualText.fromMap(Map<String, dynamic> m) =>
      BlogBilingualText(en: (m['en'] as String?) ?? '', ar: (m['ar'] as String?) ?? '');

  Map<String, dynamic> toMap() => {'en': en, 'ar': ar};

  BlogBilingualText copyWith({String? en, String? ar}) =>
      BlogBilingualText(en: en ?? this.en, ar: ar ?? this.ar);
}

enum BlogBlockType { paragraph, numbering, bulletPoint }

class BlogDescriptionBlock {
  final String           id;
  final BlogBlockType    type;
  final BlogBilingualText content;

  const BlogDescriptionBlock({required this.id, required this.type, required this.content});

  factory BlogDescriptionBlock.fromMap(Map<String, dynamic> m) => BlogDescriptionBlock(
    id:      (m['id'] as String?) ?? '',
    type:    BlogBlockType.values.firstWhere(
            (e) => e.name == (m['type'] as String? ?? 'paragraph'),
        orElse: () => BlogBlockType.paragraph),
    content: BlogBilingualText.fromMap((m['content'] as Map<String, dynamic>?) ?? {}),
  );

  Map<String, dynamic> toMap() => {'id': id, 'type': type.name, 'content': content.toMap()};

  BlogDescriptionBlock copyWith({String? id, BlogBlockType? type, BlogBilingualText? content}) =>
      BlogDescriptionBlock(id: id ?? this.id, type: type ?? this.type, content: content ?? this.content);
}

class BlogPostModel {
  final String             id;
  final String             status;       // 'published' | 'draft'
  final String             imageUrl;
  final BlogBilingualText  question;
  final BlogBilingualText  shortDescription;
  final BlogBilingualText  buttonLabel;
  final BlogBilingualText  descriptionTitle;
  final List<BlogDescriptionBlock> blocks;
  final DateTime?          createdAt;

  const BlogPostModel({
    required this.id,
    this.status           = 'draft',
    this.imageUrl         = '',
    required this.question,
    required this.shortDescription,
    required this.buttonLabel,
    required this.descriptionTitle,
    this.blocks           = const [],
    this.createdAt,
  });

  factory BlogPostModel.empty() => BlogPostModel(
      id: '', question: const BlogBilingualText(),
      shortDescription: const BlogBilingualText(),
      buttonLabel: const BlogBilingualText(),
      descriptionTitle: const BlogBilingualText());

  factory BlogPostModel.fromMap(String docId, Map<String, dynamic> m) {
    DateTime? createdAt;
    try {
      final raw = m['createdAt'];
      if (raw != null) createdAt = DateTime.fromMillisecondsSinceEpoch(raw.millisecondsSinceEpoch as int);
    } catch (_) {}
    return BlogPostModel(
      id: docId, status: (m['status'] as String?) ?? 'draft',
      imageUrl: (m['imageUrl'] as String?) ?? '',
      question: BlogBilingualText.fromMap((m['question'] as Map<String, dynamic>?) ?? {}),
      shortDescription: BlogBilingualText.fromMap((m['shortDescription'] as Map<String, dynamic>?) ?? {}),
      buttonLabel: BlogBilingualText.fromMap((m['buttonLabel'] as Map<String, dynamic>?) ?? {}),
      descriptionTitle: BlogBilingualText.fromMap((m['descriptionTitle'] as Map<String, dynamic>?) ?? {}),
      blocks: ((m['blocks'] as List?) ?? [])
          .map((b) => BlogDescriptionBlock.fromMap(b as Map<String, dynamic>)).toList(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status, 'imageUrl': imageUrl,
    'question': question.toMap(), 'shortDescription': shortDescription.toMap(),
    'buttonLabel': buttonLabel.toMap(), 'descriptionTitle': descriptionTitle.toMap(),
    'blocks': blocks.map((b) => b.toMap()).toList(),
  };

  BlogPostModel copyWith({
    String? id, String? status, String? imageUrl,
    BlogBilingualText? question, BlogBilingualText? shortDescription,
    BlogBilingualText? buttonLabel, BlogBilingualText? descriptionTitle,
    List<BlogDescriptionBlock>? blocks, DateTime? createdAt,
  }) => BlogPostModel(
      id: id ?? this.id, status: status ?? this.status, imageUrl: imageUrl ?? this.imageUrl,
      question: question ?? this.question, shortDescription: shortDescription ?? this.shortDescription,
      buttonLabel: buttonLabel ?? this.buttonLabel, descriptionTitle: descriptionTitle ?? this.descriptionTitle,
      blocks: blocks ?? this.blocks, createdAt: createdAt ?? this.createdAt);
}