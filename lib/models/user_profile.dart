class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isGuest;
  final double monthlyBudget;
  final String currencySymbol;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
    this.monthlyBudget = 25000.0,
    this.currencySymbol = '₹',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'monthlyBudget': monthlyBudget,
      'currencySymbol': currencySymbol,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? 'Guest User',
      email: json['email'] as String? ?? 'guest@minimal.local',
      photoUrl: json['photoUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 25000.0,
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
    );
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
    double? monthlyBudget,
    String? currencySymbol,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
