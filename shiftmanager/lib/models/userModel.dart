class UserModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String firebaseAuthId;

  UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.firebaseAuthId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      firebaseAuthId: map['firebaseAuthId']?.toString() ?? '',
    );
  }

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
