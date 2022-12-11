import 'package:hisma_visual_monitor/src/visual_monitor/dto/c2s/registration_request_dto.dart';
import 'package:hisma_visual_monitor/src/visual_monitor/dto/message.dart';
import 'package:hisma_visual_monitor/src/visual_monitor/dto/s2c/fire_message_dto.dart';
import 'package:hisma_visual_monitor/src/visual_monitor/dto/s2c/registration_response_dto.dart';
import 'package:test/test.dart';

void main() {
  group('DTO message tests', () {
    test('FireMessage test', () {
      final fm = FireMessageDTO(event: 'someEvent', machine: 'someMachine');
      final jsonStr = messageToJson(fm);
      expect(
        jsonStr,
        equals(
          '{"type":"FIRE","payload":"{\\"event\\":\\"someEvent\\",\\"machine\\":\\"someMachine\\"}"}',
        ),
      );
      final m = messageFromJson(jsonStr);
      expect(m, isA<FireMessageDTO>());
      final rfm = m as FireMessageDTO;
      expect(rfm.event, equals('someEvent'));
    });
    test('RegistrationData test', () {
      final rdm = RegistrationRequestDTO(
        hostname: 'hostname1',
        domain: 'domain1',
        smId: 'smId1',
        diagram: 'diagram1',
        children: ['child1', 'child2', 'child3'],
      );

      final jsonStr = messageToJson(rdm);
      // print(jsonStr);
      expect(
        jsonStr,
        '{"type":"REGISTRATION_DATA","payload":"{\\"hostname\\":\\"hostname1\\",'
        '\\"domain\\":\\"domain1\\",\\"smId\\":\\"smId1\\",\\"diagram\\":\\"diagram1\\",'
        '\\"children\\":[\\"child1\\",\\"child2\\",\\"child3\\"]}"}',
      );

      final m = messageFromJson(jsonStr);

      expect(m, isA<RegistrationRequestDTO>());
      final rd = m as RegistrationRequestDTO;
      expect(rd.hostname, equals('hostname1'));
      expect(rd.domain, equals('domain1'));
      expect(rd.smId, equals('smId1'));
      expect(rd.children, equals(['child1', 'child2', 'child3']));
      expect(rd.diagram, equals('diagram1'));
    });

    test('RegistrationStatus test', () {
      final rdm =
          RegistrationResponseDTO(successful: true, message: 'message1');
      final jsonStr = messageToJson(rdm);
      // print(jsonStr);

      expect(
        jsonStr,
        '{"type":"REGISTRATION","payload":"{\\"successful\\":true,\\"message\\":\\"message1\\"}"}',
      );

      final m = messageFromJson(jsonStr);
      expect(m, isA<RegistrationResponseDTO>());
      final rd = m as RegistrationResponseDTO;
      expect(rd.successful, equals(true));
      expect(rd.message, equals('message1'));
    });
  });
}
