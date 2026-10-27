class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.district,
    required this.sports,
    this.avatarUrl,
    this.ratingSum = 0,
    this.ratingCount = 0,
    this.matchesPlayed = 0,
    this.noShows = 0,
    this.lateLeaves = 0,
    this.lateCancels = 0,
  });

  final String uid;
  final String displayName;
  final String district;
  final Map<String, int> sports;
  final String? avatarUrl;
  final int ratingSum;
  final int ratingCount;
  final int matchesPlayed;
  final int noShows;
  final int lateLeaves;
  final int lateCancels;

  // BR11: trung bình Bayes (5 lượt ảo 4 sao) trừ phạt, giới hạn 1–5
  double? get reputation {
    if (ratingCount == 0) return null;
    final raw = (ratingSum + 5 * 4.0) / (ratingCount + 5) - 0.3 * noShows - 0.1 * lateLeaves - 0.2 * lateCancels;
    return raw.clamp(1, 5).toDouble();
  }

  String get initials => initialsOf(displayName);

  UserProfile copyWith({String? displayName, String? district, Map<String, int>? sports}) => UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        district: district ?? this.district,
        sports: sports ?? this.sports,
        avatarUrl: avatarUrl,
        ratingSum: ratingSum,
        ratingCount: ratingCount,
        matchesPlayed: matchesPlayed,
        noShows: noShows,
        lateLeaves: lateLeaves,
        lateCancels: lateCancels,
      );
}

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  return (parts.length > 1 ? first + parts.last[0] : first).toUpperCase();
}
