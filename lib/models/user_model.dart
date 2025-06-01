class UserModel {
  final String id; // Firebase document ID
  final String username;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String birth;
  final String sex;
  final String role;
  final String cccd;
  final String avtUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.birth,
    required this.sex,
    required this.role,
    required this.cccd,
    required this.avtUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'] ?? '',
      birth: json['birth'] ?? '',
      sex: json['sex'] ?? '',
      role: json['role'] ?? '',
      cccd: json['cccd'] ?? '',
      avtUrl: json['avtUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'birth': birth,
      'sex': sex,
      'role': role,
      'cccd': cccd,
      'avtUrl': avtUrl,
    };
  }
}
