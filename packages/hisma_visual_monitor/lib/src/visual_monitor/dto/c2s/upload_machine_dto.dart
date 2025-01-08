import 'dart:convert';

import '../message.dart';

class UploadMachineDTO implements Message {
  UploadMachineDTO({
    required this.hostname,
    required this.domain,
    required this.smId,
    required this.diagram,
    // TODO: children ony added here as a quick test for providing
    // children in UploadMachineDTO as well exactly like in
    // RegistrationRequestDTO. It shall be refactored to use only one
    // of them.
    required this.children,
  });

  factory UploadMachineDTO.fromMap(Map<String, dynamic> map) {
    return UploadMachineDTO(
      hostname: map[_hostname] as String,
      domain: map[_domain] as String,
      smId: map[_smId] as String,
      diagram: map[_diagram] as String,
      children: List<String>.from(map[_children] as Iterable<dynamic>),
    );
  }

  factory UploadMachineDTO.fromJson(String source) => UploadMachineDTO.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _hostname: hostname,
      _domain: domain,
      _smId: smId,
      _diagram: diagram,
      _children: children,
    };
  }

  @override
  String toJson() => json.encode(toMap());

  /// hostname to distinguish between machines in visualization server.
  final String hostname;
  static const _hostname = 'hostname';

  /// domain is to distinguish between processes on the same client machine
  /// by the visualization server. It is better than using pid that always
  /// changes thus makes impossible to simply (and automatically)
  final String domain;
  static const _domain = 'domain';

  /// State machine identifier unique for a client process.
  final String smId;
  static const _smId = 'smId';

  /// Diagram representing a state machine that visualization server will
  /// render for connecting viewers in wbe browsers.
  final String diagram;
  static const _diagram = 'diagram';

  /// Set of state machine ids representing the regions of the state machine.
  final List<String> children;
  static const _children = 'children';

  @override
  String get name => sName;
  static const sName = 'UPLOAD_MACHINE_DATA';
}
