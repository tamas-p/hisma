import 'dart:convert';

import '../message.dart';

class RegistrationResponseDTO implements Message {
  RegistrationResponseDTO({
    required this.successful,
    this.message,
  });

  factory RegistrationResponseDTO.fromJson(String source) =>
      RegistrationResponseDTO.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  factory RegistrationResponseDTO.fromMap(Map<String, dynamic> map) {
    return RegistrationResponseDTO(
      successful: map[_successful] as bool,
      message: map[_message] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _successful: successful,
      _message: message,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  @override
  String get name => sName;
  static const sName = 'REGISTRATION';

  bool successful;
  static const _successful = 'successful';

  String? message;
  static const _message = 'message';
}
