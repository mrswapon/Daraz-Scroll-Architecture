import '../../domain/entities/user_entity.dart';

class UserDto {
  final int id;
  final String email;
  final String username;
  final NameDto name;
  final String phone;
  final AddressDto address;

  const UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      name: NameDto.fromJson(json['name'] as Map<String, dynamic>),
      phone: json['phone'] as String,
      address: AddressDto.fromJson(json['address'] as Map<String, dynamic>),
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      name: name.toEntity(),
      phone: phone,
      address: address.toEntity(),
    );
  }
}

class NameDto {
  final String firstname;
  final String lastname;

  const NameDto({required this.firstname, required this.lastname});

  factory NameDto.fromJson(Map<String, dynamic> json) {
    return NameDto(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
    );
  }

  Name toEntity() {
    return Name(firstname: firstname, lastname: lastname);
  }
}

class AddressDto {
  final String city;
  final String street;
  final int number;
  final String zipcode;

  const AddressDto({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      city: json['city'] as String,
      street: json['street'] as String,
      number: json['number'] as int,
      zipcode: json['zipcode'] as String,
    );
  }

  Address toEntity() {
    return Address(
      city: city,
      street: street,
      number: number,
      zipcode: zipcode,
    );
  }
}
