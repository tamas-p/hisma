import 'dart:async';
import 'dart:io';

import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../../../assistance.dart';

mixin BrowserNotifier {
  static final _log = getLogger('$BrowserNotifier');

  final _viewers = <WebSocket>{};
  void Function()? _cleanup;

  /// [cleanup] will be called when all listener WebSockets are closed.
  void addListener({
    required WebSocket listener,
    void Function()? cleanup,
    void Function(Message)? processMessage,
  }) {
    _cleanup = cleanup;
    _viewers.add(listener);
    listener.listen(
      (dynamic data) {
        final message = messageFromUriEncodedJson(data as String);

        // print('SUBSCRIPTION data received: $eventDTO');
        processMessage?.call(message);
      },
      cancelOnError: true,
      onDone: () {
        _log.info('Subscriber disconnected.');
        removeListener(listener);
        listener.close();
      },
      onError: (Object error) {
        _log.warning('Subscriber connection error: $error.');
        removeListener(listener);
        listener.close();
      },
    );

    _log.fine('Registered listening WebSockets: ${_viewers.length}');
  }

  bool thereIsSubscriber() {
    return _viewers.isNotEmpty;
  }

  void removeListener(WebSocket listener) {
    _viewers.remove(listener);
    if (_viewers.isEmpty) _cleanup?.call();
  }

  Timer? _timer;

  /// Send notification to all registered WebSockets from the browser.
  /// Notifications inside a time window are merged to a single notification
  /// to avoid unnecessarily frequent notifications.
  void notifyViewers() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), () {
      for (final ws in _viewers) {
        ws.add('RELOAD');
      }
    });
  }
}
