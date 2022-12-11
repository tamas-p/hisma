// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:visma/src/assistance.dart';
import 'package:visma/src/visualizer/plantuml/plantuml_hacker.dart';
import 'package:visma/src/visualizer/visual_monitor/server/visualization_server.dart';

final _log = getLogger(appName);

const _bind = 'bind';
const _port = 'port';

const _plantumlPublic = 'plantuml_public';
const _plantumlUrl = 'plantuml_url';
const _plantumlPort = 'plantuml_port';
const _plantumlJar = 'plantuml_jar';
const _plantumlBind = 'plantuml_bind';

const _help = 'help';

const defaultPort = 4020;

ArgResults parseArgs(List<String> args) {
  final parser = ArgParser();

  parser.addOption(
    _port,
    abbr: 'p',
    help: 'Port of the $appName service listening on.',
  );

  parser.addOption(
    _bind,
    abbr: 'b',
    help: 'Specify bind address of the $appName service.',
  );

  parser.addFlag(
    _plantumlPublic,
    negatable: false,
    help: 'The public PlantUML service will be used as renderer.',
  );

  parser.addOption(
    _plantumlUrl,
    help: 'PlantUML service at this URL will be used to render.',
  );

  parser.addOption(
    _plantumlPort,
    help: 'Port of the PlantUML renderer service that will be started.',
  );

  parser.addOption(
    _plantumlJar,
    help: 'Specify PlantUML jar location.',
  );

  parser.addOption(
    _plantumlBind,
    help: 'Specify bind address of the local PlantUML service to be started.',
  );

  parser.addFlag(
    _help,
    abbr: 'h',
    negatable: false,
    help: 'Shows this help.',
  );

  final argResults = parser.parse(args);

  if (argResults[_help] == true) {
    print('''
A visualization server for Hisma the hierarchical state machine.
Without parameters it will try running the 'plantuml -picoweb' command as the renderer for $appName.

Usage: $appName [--bind=BIND] [--port=PORT] [--plantuml_public] | [--plantuml_url=URL] | [--plantuml_jar=JAR --plantuml_bind=BIND --plantuml_port=PORT] [--help]

Options:''');
    print(parser.usage);
    exit(1);
  }

  return argResults;
}

Future<void> main(List<String> args) async {
  runZonedGuarded(() async {
    initLogging();
    final argResults = parseArgs(args);

    late final Converter converter;
    if (argResults[_plantumlPublic] == true) {
      _log.warning(
        '+---------------------------------------------------------------------------------+',
      );
      _log.warning(
        '| Started with --plantuml_public.                                                 |',
      );
      _log.warning(
        '|                                                                                 |',
      );
      _log.warning(
        '| visma will use the public PlantUML service at https://www.plantuml.com/plantuml |',
      );
      _log.warning(
        '| Your diagrams will be transferred to that service over the Internet.            |',
      );
      _log.warning(
        '| This besides its security implications also impacts performance.                |',
      );
      _log.warning(
        '| Use this mode ONLY if you accept these conditions.                              |',
      );
      _log.warning(
        '+---------------------------------------------------------------------------------+',
      );
      converter = Converter.public();
    } else if (argResults[_plantumlUrl] != null) {
      final url = argResults[_plantumlUrl] as String;
      converter = Converter.url(url);
    } else {
      final jarPath = argResults[_plantumlJar] as String?;
      final pv = argResults[_plantumlPort] as String?;
      final portValue = pv == null ? defaultPort : int.parse(pv);
      final bindValue = argResults[_plantumlBind] as String?;
      converter = await Converter.createLocal(
        jar: jarPath,
        port: portValue,
        bind: bindValue,
      );
    }

    final pv = argResults[_port] as String?;
    final portValue = pv == null ? null : int.parse(pv);
    final bindValue = argResults[_bind] as String?;
    final vs = VisualizationServer(
      converter: converter,
      bind: bindValue,
      port: portValue,
    );
    await vs.startServer();
    print('visFinished.');
  }, (error, stackTrace) {
    _log.severe('Shutting down due to $error');
    exit(1);
  });
}
