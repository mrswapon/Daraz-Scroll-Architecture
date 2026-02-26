import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String email;
  final String username;
  final NameModel name;
  final String phone;
  final AddressModel address;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      name: NameModel.fromJson(json['name'] as Map<String, dynamic>),
      phone: json['phone'] as String,
      address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
    );
  }

  String get fullName => '${name.firstname} ${name.lastname}';

  @override
  List<Object?> get props => [id, email, username, name, phone, address];
}

class NameModel extends Equatable {
  final String firstname;
  final String lastname;

  const NameModel({required this.firstname, required this.lastname});

  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
    );
  }

  @override
  List<Object?> get props => [firstname, lastname];
}

class AddressModel extends Equatable {
  final String city;
  final String street;
  final int number;
  final String zipcode;

  const AddressModel({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] as String,
      street: json['street'] as String,
      number: json['number'] as int,
      zipcode: json['zipcode'] as String,
    );
  }

  @override
  List<Object?> get props => [city, street, number, zipcode];
}
