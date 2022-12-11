import 'dart:convert';

import '../message.dart';

/// Introduced for hot-reload-fix. Search source files for hot-reload-fix.
class DisconnectRequestDTO implements Message {
  DisconnectRequestDTO({
    this.message,
  });

  factory DisconnectRequestDTO.fromJson(String source) =>
      DisconnectRequestDTO.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  factory DisconnectRequestDTO.fromMap(Map<String, dynamic> map) {
    return DisconnectRequestDTO(
      message: map[_message] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _message: message,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  @override
  String get name => sName;
  static const sName = 'DISCONNECT_REQUEST';

  String? message;
  static const _message = 'message';
}
