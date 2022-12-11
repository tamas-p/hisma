import 'dart:io';
import 'dart:isolate';

import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';

import '../../../assistance.dart';
import '../../plantuml/plantuml_hacker.dart';
import '../constants.dart';
import 'statemachine_manager.dart';

class VisualizationServer {
  VisualizationServer({
    required this.converter,
    String? bind,
    int? port,
  })  : bind = bind ?? bHost,
        port = port ?? cPort;
  static final _log = getLogger('$VisualizationServer');

  final String bind;
  final int port;
  final Converter converter;
  late final StateMachineManager _stateMachineManager;

  Future<void> startServer() async {
    _stateMachineManager = StateMachineManager(converter);
    final server = await HttpServer.bind(bind, port);
    _log.info(
      'SM PlantUML visualization server stated on '
      '${server.address}:${server.port}',
    );
    await for (final request in server) {
      try {
        // We are not await here as we want request to be
        // served asynchronously.
        _serve(request);
      } catch (err) {
        _log.warning('Caught error: $err');
        _setBadRequest(request);
      }
    }
  }

  Future<void> _serve(HttpRequest request) async {
    _log.fine('Request received (uri): ${request.uri}');

    final map = <String, Future<void> Function(HttpRequest, String)>{
      // Static
      javascript: _processJavaScriptRequest,
      css: _processCSSRequest,
      // Registration
      cord: _processCordRequest,
      // Machine
      machinePage: _processMachinePageRequest,
      machineRendered: _processMachineRenderRequest,
      machineSubscribe: _processMachineSubscribe,
      // Overview
      overviewPage: _processOverviewPageRequest,
      overviewRendered: _processOverviewRenderRequest,
      overviewSubscribe: _processOverviewSubscribe,
    };

    // Set currentPath to root if "/" is the request.uri.
    final currentPath = request.uri.path == '/' ? root : request.uri.path;

    var served = false;
    for (final e in map.entries) {
      final path = e.key;
      final process = e.value;

      if (currentPath.startsWith(path)) {
        final remaining = currentPath.substring(path.length);
        _log.fine('Serving $path with $remaining');
        await process(request, remaining);
        served = true;
        break;
      }
    }

    if (served) {
      _log.fine('Request served.');
      request.response.close();
    } else {
      _log.warning('ERROR: "$currentPath" is not found.');
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('This is 404.');
      request.response.close();
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _processCordRequest(
    HttpRequest request,
    String argument,
  ) async {
    _log.fine('Cord request received');
    late final WebSocket ws;
    try {
      ws = await WebSocketTransformer.upgrade(request);
      _log.fine('Cord upgrade completed');
      await _stateMachineManager.addClient(ws);
    } catch (err) {
      _log.warning('Could not upgrade to WebSocket: $err');
      _setBadRequest(request);
    }
  }

  Future<void> _processJavaScriptRequest(
    HttpRequest request,
    String argument,
  ) async {
    await _writeJavaScriptContent(request: request, fileName: javascriptFile);
  }

  Future<void> _processCSSRequest(
    HttpRequest request,
    String argument,
  ) async {
    await _writeCSSContent(request: request, fileName: cssFile);
  }

  Future<void> _processMachinePageRequest(
    HttpRequest request,
    String argument,
  ) async {
    await _writePageContent(request: request, fileName: machineHtmlFile);
  }

  Future<void> _processMachineSubscribe(
    HttpRequest request,
    String argument,
  ) async {
    try {
      final websocket = await WebSocketTransformer.upgrade(request);
      _stateMachineManager.addMachineListener(
        uniqueSmIdPath: argument,
        websocket: websocket,
      );
    } catch (err) {
      _log.warning('Caught error: $err');
      _setBadRequest(request);
    }
  }

  Future<void> _processOverviewSubscribe(
    HttpRequest request,
    String argument,
  ) async {
    try {
      final websocket = await WebSocketTransformer.upgrade(request);
      _stateMachineManager.addOverviewListener(websocket: websocket);
    } catch (err) {
      _log.warning('Caught error: $err');
      _setBadRequest(request);
    }
  }

  Future<void> _processOverviewPageRequest(
    HttpRequest request,
    String argument,
  ) async {
    await _writePageContent(request: request, fileName: overviewHtmlFile);
  }

  Future<void> _processOverviewRenderRequest(
    HttpRequest request,
    String argument,
  ) async {
    final svg = await _stateMachineManager.renderOverview();
    _writeSvg(request: request, svg: svg);
  }

  Future<void> _processMachineRenderRequest(
    HttpRequest request,
    String uniqueSmIdPath,
  ) async {
//     const svg = '''
//     <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
//   <path d="M50,30c9-22 42-24 48,0c5,40-40,40-48,65c-8-25-54-25-48-65c 6-24 39-22 48,0 z" fill="#F00" stroke="#000"/>
// </svg>
//     ''';
    final svg = await _stateMachineManager.renderMachine(uniqueSmIdPath);
    _writeSvg(request: request, svg: svg);
    _log.fine('Response sent:\n$svg');
  }

  // ---------------------------------------------------------------------------

  void _setBadRequest(HttpRequest request) {
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write('Bad request.');
  }

  Future<void> _writeCSSContent({
    required HttpRequest request,
    required String fileName,
  }) async {
    _log.fine('Page: $fileName');
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'text/css; charset=UTF-8',
    );
    await _writeFileContent(request: request, fileName: fileName);
  }

  Future<void> _writeJavaScriptContent({
    required HttpRequest request,
    required String fileName,
  }) async {
    _log.fine('Page: $fileName');
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'text/javascript; charset=UTF-8',
    );
    await _writeFileContent(request: request, fileName: fileName);
  }

  Future<void> _writePageContent({
    required HttpRequest request,
    required String fileName,
  }) async {
    _log.fine('Page: $fileName');
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'text/html; charset=UTF-8',
    );
    await _writeFileContent(request: request, fileName: fileName);
  }

  Future<void> _writeFileContent({
    required HttpRequest request,
    required String fileName,
  }) async {
    final path = 'package:visma/src/'
        'visualizer/visual_monitor/page/$fileName';
    final uri = await Isolate.resolvePackageUri(Uri.parse(path));
    final pageContent =
        uri != null ? await File.fromUri(uri).readAsString() : null;
    request.response.write(pageContent);
  }

  Future<void> _writeSvg({
    required HttpRequest request,
    required String svg,
  }) async {
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      'image/svg+xml; charset=UTF-8',
    );
    request.response.writeln(svg);
  }
}
