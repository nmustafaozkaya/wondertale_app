class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isPremium;
  final int dailyStoriesGenerated;
  final String lastQuotaResetDate; // YYYY-MM-DD format

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.isPremium = false,
    this.dailyStoriesGenerated = 0,
    required this.lastQuotaResetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isPremium': isPremium,
      'dailyStoriesGenerated': dailyStoriesGenerated,
      'lastQuotaResetDate': lastQuotaResetDate,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'],
      displayName: map['displayName'],
      isPremium: map['isPremium'] ?? false,
      dailyStoriesGenerated: map['dailyStoriesGenerated'] ?? 0,
      lastQuotaResetDate: map['lastQuotaResetDate'] ?? DateTime.now().toIso8601String().substring(0, 10),
    );
  }
}
