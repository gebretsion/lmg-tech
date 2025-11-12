class User {
  final String id;
  final String email;
  final String fullName;
  final int phonenumber;
  final String address;
  final String profilePictureUrl;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phonenumber,
    required this.address,
    required this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        fullName: json['fullName'],
        phonenumber: json['phonenumber'],
        address: json['address'],
        profilePictureUrl: json['profilePictureUrl'],
      );
}
