import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final Name name;
  final String phone;
  final Address address;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
  });

  String get fullName => '${name.firstname} ${name.lastname}';

  @override
  List<Object?> get props => [id, email, username, name, phone, address];
}

class Name extends Equatable {
  final String firstname;
  final String lastname;

  const Name({required this.firstname, required this.lastname});

  @override
  List<Object?> get props => [firstname, lastname];
}

class Address extends Equatable {
  final String city;
  final String street;
  final int number;
  final String zipcode;

  const Address({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
  });

  @override
  List<Object?> get props => [city, street, number, zipcode];
}
