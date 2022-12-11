import 'dart:convert';

import '../message.dart';

class ToggleExpandDTO extends Message {
  ToggleExpandDTO({
    required this.id,
    required this.expand,
  });

  factory ToggleExpandDTO.fromMap(Map<String, dynamic> map) {
    return ToggleExpandDTO(
      id: map[_id] as String,
      expand: map[_expand] as bool,
    );
  }

  factory ToggleExpandDTO.fromJson(String source) =>
      ToggleExpandDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _id: id,
      _expand: expand,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  final String id;
  static const _id = 'id';

  final bool expand;
  static const _expand = 'expand';

  @override
  String get name => sName;
  static const sName = 'TOGGLE_EXPAND';

  @override
  String toString() => 'ToggleExpandDTO(id: $id, expand: $expand)';
}
