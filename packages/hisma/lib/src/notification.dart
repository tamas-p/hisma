abstract class Message {}

class ExitNotificationFromRegion<E> extends Message {
  ExitNotificationFromRegion({
    required this.event,
    required this.arg,
  });
  E event;
  dynamic arg;
}

class ExitNotificationFromMachine<E> extends Message {
  ExitNotificationFromMachine({
    required this.exitPointId,
    required this.arg,
  });
  E exitPointId;
  dynamic arg;
}
