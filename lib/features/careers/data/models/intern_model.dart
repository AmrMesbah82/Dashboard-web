// ******************* FILE INFO *******************
// File Name: intern_model.dart

class InternModel {
  final String id;
  final String photoUrl;
  final String firstName;
  final String lastName;
  final String position;
  final String degrees;
  final DateTime? joinedDate;
  final String whatHaveILearned;
  // final List<String> tags;

  const InternModel({
    required this.id,
    this.photoUrl = '',
    required this.firstName,
    required this.lastName,
    this.position = '',
    this.degrees = '',
    this.joinedDate,
    required this.whatHaveILearned,
    // this.tags = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  String get joinDateLabel {
    if (joinedDate == null) return '';
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Joined as Intern: ${joinedDate!.day} ${months[joinedDate!.month]} ${joinedDate!.year}';
  }

  InternModel copyWith({
    String? id,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? position,
    String? degrees,
    DateTime? joinedDate,
    String? whatHaveILearned,
    // List<String>? tags,
  }) {
    return InternModel(
      id:               id               ?? this.id,
      photoUrl:         photoUrl         ?? this.photoUrl,
      firstName:        firstName        ?? this.firstName,
      lastName:         lastName         ?? this.lastName,
      position:         position         ?? this.position,
      degrees:          degrees          ?? this.degrees,
      joinedDate:       joinedDate       ?? this.joinedDate,
      whatHaveILearned: whatHaveILearned ?? this.whatHaveILearned,
      // tags:             tags             ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':               id,
    'photoUrl':         photoUrl,
    'firstName':        firstName,
    'lastName':         lastName,
    'position':         position,
    'degrees':          degrees,
    'joinedDate':       joinedDate?.toIso8601String(),
    'whatHaveILearned': whatHaveILearned,
    // 'tags':             tags,
  };

  /// Nested template for [FlatCodec.decode]. `tags` is a string list, so it
  /// flattens to Tags_Count + Tags_0, Tags_1, …
  static Map<String, dynamic> get flatTemplate => {
        'id': '',
        'photoUrl': '',
        'firstName': '',
        'lastName': '',
        'position': '',
        'degrees': '',
        'joinedDate': '',
        'whatHaveILearned': '',
        // 'tags': [''],
      };

  factory InternModel.fromMap(Map<String, dynamic> map) => InternModel(
    id:               map['id']               as String? ?? '',
    photoUrl:         map['photoUrl']         as String? ?? '',
    firstName:        map['firstName']        as String? ?? '',
    lastName:         map['lastName']         as String? ?? '',
    position:         map['position']         as String? ?? '',
    degrees:          map['degrees']          as String? ?? '',
    joinedDate:       map['joinedDate'] != null
        ? DateTime.tryParse(map['joinedDate'] as String)
        : null,
    whatHaveILearned: map['whatHaveILearned'] as String? ?? '',
    // tags:             (map['tags'] as List<dynamic>?)
    //     ?.map((e) => e as String)
    //     .toList() ?? [],
  );

  factory InternModel.empty() => InternModel(
    id:               '',
    firstName:        '',
    lastName:         '',
    whatHaveILearned: '',
  );
}