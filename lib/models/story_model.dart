class StoryModel {
  final String id;
  final String title;
  final String content;
  final String? illustrationPrompt;
  final String? imageBase64;
  final String theme;
  final String mood;
  final String ageGroup;
  final String childName;
  final String language;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.title,
    required this.content,
    this.illustrationPrompt,
    this.imageBase64,
    required this.theme,
    required this.mood,
    required this.ageGroup,
    required this.childName,
    required this.language,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'illustrationPrompt': illustrationPrompt,
      'imageBase64': imageBase64,
      'theme': theme,
      'mood': mood,
      'ageGroup': ageGroup,
      'childName': childName,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      illustrationPrompt: map['illustrationPrompt'],
      imageBase64: map['imageBase64'],
      theme: map['theme'] ?? 'forest',
      mood: map['mood'] ?? 'calming',
      ageGroup: map['ageGroup'] ?? '5-7',
      childName: map['childName'] ?? '',
      language: map['language'] ?? 'tr',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
