import 'dart:convert';

class UserModel {
  String? id;
  String name;
  String userName;
  List<String> addresses;
  String contactNumber;
  String? type;
  bool? isApproved;
  String? organizationName;
  String? description;
  List<String>? proofs;
  bool? isOpen;

  UserModel({
    this.id,
    required this.name,
    required this.userName,
    required this.addresses,
    required this.contactNumber,
    required this.type,
    this.isApproved,
    this.organizationName,
    this.description,
    this.proofs,
    this.isOpen
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      userName: json['userName'],
      addresses: List<String>.from(json['addresses']),
      contactNumber: json['contactNumber'],
      type: json['type'],
      isApproved: json['isApproved'],
      organizationName: json['organizationName'],
      description: json['description'],
      proofs: json['proofs'] != null ? List<String>.from(json['proofs']) : null,
      isOpen: json['isOpen']
    );
  }

  static List<UserModel> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<UserModel>((dynamic json) => UserModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson(UserModel userModel) {
    return {
      'name': name,
      'userName': userName,
      'addresses': addresses,
      'contactNumber': contactNumber,
      'type': type,
      'isApproved': isApproved,
      'organizationName': organizationName,
      'description': description,
      'proofs': proofs,
      'isOpen': isOpen
    };
  }
}