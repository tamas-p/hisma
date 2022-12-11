class Theme {
  Theme({
    required this.lineColor,
    required this.highlightColor,
    required this.backgroundColor,
    required this.activeTransitionColor,
    required this.passiveTransitionColor,
    required this.machineStyleStopped,
    required this.machineStyleStarted,
    required this.activeStateColor,
    required this.passiveStateColor,
    required this.connectorStyle,
  });

  factory Theme.dark() => Theme(
        lineColor: 'Gray',
        highlightColor: 'Navy',
        backgroundColor: '#18191a',
        activeTransitionColor: 'DeepSkyBlue',
        passiveTransitionColor: 'Gray',
        machineStyleStopped: '#transparent;line.dashed',
        machineStyleStarted: '#transparent;line.dashed;line:Red',
        activeStateColor: '721717',
        passiveStateColor: 'transparent',
        connectorStyle: '#yellow',
      );

  factory Theme.light() => Theme(
        lineColor: 'Gray',
        highlightColor: 'Navy',
        backgroundColor: 'SeaShell',
        activeTransitionColor: 'DeepSkyBlue',
        passiveTransitionColor: 'Gray',
        machineStyleStopped: '#transparent;line.dashed',
        machineStyleStarted: '#transparent;line.dashed;line:Wheat',
        activeStateColor: 'Wheat',
        passiveStateColor: 'transparent',
        connectorStyle: '#yellow',
      );

  String lineColor;

  String highlightColor;

  // Can not be transparent as an active parent state color
  // would be seen through in all child regions.
  String backgroundColor;

  String passiveTransitionColor;
  String activeTransitionColor;

  String machineStyleStopped;
  String machineStyleStarted;

  String activeStateColor;

  String passiveStateColor;

  String connectorStyle;
}
