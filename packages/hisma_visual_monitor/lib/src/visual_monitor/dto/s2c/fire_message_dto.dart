import 'dart:convert';

import '../message.dart';

class FireMessageDTO extends Message {
  FireMessageDTO({
    required this.event,
    required this.machine,
  });

  factory FireMessageDTO.fromMap(Map<String, dynamic> map) {
    return FireMessageDTO(
      event: map[_event] as String,
      machine: map[_machine] as String,
    );
  }

  factory FireMessageDTO.fromJson(String source) =>
      FireMessageDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{_event: event, _machine: machine};
  }

  @override
  String toJson() => json.encode(toMap());

  final String event;
  static const _event = 'event';

  final String machine;
  static const _machine = 'machine';

  @override
  String get name => sName;
  static const sName = 'FIRE';

  @override
  String toString() => 'FireMessageDTO(event: $event, machine: $machine)';
}
