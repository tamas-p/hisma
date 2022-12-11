import 'dart:convert';

import 'c2s/registration_request_dto.dart';
import 'c2s/upload_machine_dto.dart';
import 's2c/disconnect_request_dto.dart';
import 's2c/fire_message_dto.dart';
import 's2c/registration_response_dto.dart';
import 's2c/toggle_expand_dto.dart';

//------------------------------------------------------------------------------

Message messageFromUriEncodedJson(String source) =>
    _messageFromMessageContainer(MessageContainer.fromUriEncodedJson(source));

Message messageFromJson(String source) =>
    _messageFromMessageContainer(MessageContainer.fromJson(source));

Message _messageFromMessageContainer(MessageContainer messageContainer) {
  switch (messageContainer.type) {
    // c2s section
    case RegistrationRequestDTO.sName:
      return RegistrationRequestDTO.fromJson(messageContainer.payload);
    case UploadMachineDTO.sName:
      return UploadMachineDTO.fromJson(messageContainer.payload);
    // s2c section
    case RegistrationResponseDTO.sName:
      return RegistrationResponseDTO.fromJson(messageContainer.payload);
    case DisconnectRequestDTO.sName:
      return DisconnectRequestDTO.fromJson(messageContainer.payload);
    case FireMessageDTO.sName:
      return FireMessageDTO.fromJson(messageContainer.payload);
    case ToggleExpandDTO.sName:
      return ToggleExpandDTO.fromJson(messageContainer.payload);
    default:
      throw 'Unsupported message type: ${messageContainer.type}';
  }
}

String messageToJson(Message m) {
  final mc = MessageContainer(type: m.name, payload: m.toJson());
  return mc.toJson();
}

String messageUriEncodedToJson({
  required Message message,
}) {
  final mc = MessageContainer(
    type: message.name,
    payload: message.toJson(),
  );
  return mc.toUriEncodedJson();
}
//------------------------------------------------------------------------------

class MessageContainer {
  MessageContainer({
    required this.type,
    required this.payload,
  });

  factory MessageContainer.fromMap(Map<String, dynamic> map) {
    return MessageContainer(
      type: map[_typeName] as String,
      payload: map[_payLoad] as String,
    );
  }
  factory MessageContainer.fromJson(String source) =>
      MessageContainer.fromMap(json.decode(source) as Map<String, dynamic>);

  factory MessageContainer.fromUriEncodedJson(String source) =>
      MessageContainer.fromJson(Uri.decodeComponent(source));

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _typeName: type,
      _payLoad: payload,
    };
  }

  String toJson() => json.encode(toMap());
  String toUriEncodedJson() => Uri.encodeComponent(json.encode(toMap()));

  String type;
  static const _typeName = 'type';

  String payload;
  static const _payLoad = 'payload';
}

//------------------------------------------------------------------------------

abstract class Message {
  String get name;
  String toJson();
}
