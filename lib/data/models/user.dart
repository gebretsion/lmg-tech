class User {
  final String id;
  final String email;
  final String? fullName;
  final int? phonenumber;
  final String? address;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.phonenumber,
    this.address,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      phonenumber: json['phonenumber'] != null
          ? int.tryParse(json['phonenumber'].toString())
          : null,
      address: json['address']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phonenumber': phonenumber,
      'address': address,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
