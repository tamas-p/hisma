import 'dart:convert';

String getSvgText(String message, {String? description}) {
  final sb = StringBuffer();
  //<svg viewBox="-200 0 1000 300" xmlns="http://www.w3.org/2000/svg">
  sb.write(
    '''
<svg viewBox="0 0 1920 580" xmlns="http://www.w3.org/2000/svg">
  <style>
    .small { font: italic 13px sans-serif; }
    .heavy { font: bold 30px sans-serif; }
    .error { font: normal 30px serif; fill: red; }
  </style>
  <text x="0%" y="0%" class="error">
  <tspan x="0" dy="1.2em">$message</tspan>
  ''',
  );

  if (description != null) {
    const ls = LineSplitter();
    final lines = ls.convert(description);
    for (final line in lines) {
      final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(line);
      sb.writeln('<tspan x="0" dy="1.2em">$escaped</tspan>');
    }
  }

  sb.writeln(
    '''
 </text>
 </svg>
 ''',
  );

  return sb.toString();
}
