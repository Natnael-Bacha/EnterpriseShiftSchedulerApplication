class AdminModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String firebaseAuthId;

  AdminModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.firebaseAuthId,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'firebaseAuthId': firebaseAuthId,
      'createdAt': DateTime.now(),
    };
  }
}
