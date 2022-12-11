import 'package:hisma_visual_monitor/hisma_visual_monitor.dart';
import 'package:pumli/pumli.dart';

import '../../assistance.dart';
import '../visual_monitor/server/server_utility.dart';

class Converter {
  Converter._create(this._pumli);

  Converter.public() : _pumli = PumliREST(serviceURL: PumliREST.plantUmlUrl);

  Converter.url(String url) : _pumli = PumliREST(serviceURL: url);

  static Future<Converter> createLocal({
    String? jar,
    int? port,
    String? bind,
  }) async {
    final pumliServer = PumliServer(jar: jar, port: port, bind: bind);
    await pumliServer.start();

    final pumli = PumliREST(serviceURL: pumliServer.url);
    final converter = Converter._create(pumli);
    return converter;
  }

  static final _log = getLogger('$Converter');

  final PumliREST _pumli;

  Future<String> convertToSvg(String model) async {
    late String result;
    try {
      _log.fine(model);
      _log.fine('>>>>>>>>>>>>>>>>>>>>>>>');
      // final pumliCmd = PumliREST();
      final sw = Stopwatch()..start();
      final svg = await _pumli.getSVG(model);
      _log.fine('Elapse: ${sw.elapsed}');
      _log.fine('<<<<<<<<<<<<<<<<<<<<<<<');
      result = _hack(svg);
      _log.fine(result);
    } catch (e) {
      _log.severe(e);
      result = getSvgText(
        'Model conversion error:',
        description: e.toString(),
      );
    }
    return result;
  }

  String _hack(String model) {
    var tmp = '';
    tmp = _nothing(model);
    tmp = _linkUnderlineHack(tmp);
    tmp = _visServerOnClickHack(
      str: tmp,
      magic: addOnClickHereMagic,
      jsFunctionName: 'sendMessage',
    );

    return tmp;
  }

  String _nothing(String str) => str;

  /// This hack is only needed because a PlantUML||Chrome||Firefox bug
  /// renders a dashed link underline from the SVG output. See more
  /// https://github.com/plantuml/plantuml/issues/805
  String _linkUnderlineHack(String str) =>
      str.replaceAll(RegExp('textLength=".*?"'), '');

  /// This hack enables using onAction() inside any SVG elements.
  String _visServerOnClickHack({
    required String str,
    required String magic,
    required String jsFunctionName,
  }) {
    final hacked = str.replaceAllMapped(
      RegExp('font-family="$magic(.*?)"', unicode: true),
      (match) {
        assert(match.groupCount == 1);
        final eventStr = match.group(1);
        if (eventStr == null) return str;
        return 'font-family="sans-serif" cursor="pointer" onclick="top.$jsFunctionName(evt)" id="$eventStr"';
      },
    );

    return hacked;
  }
}
