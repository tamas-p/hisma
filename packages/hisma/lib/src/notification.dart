abstract class Message {}

class StateChangeNotification extends Message {}

class ExitNotificationFromRegion<E> extends Message {
  ExitNotificationFromRegion({
    required this.event,
    required this.data,
  });
  E event;
  dynamic data;
}

class ExitNotificationFromMachine<E> extends Message {
  ExitNotificationFromMachine({
    required this.exitPointId,
    required this.data,
  });
  E exitPointId;
  dynamic data;
}

class GetName extends Message {
  String? name;
}
