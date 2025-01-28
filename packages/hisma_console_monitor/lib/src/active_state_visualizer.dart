/// Convert [Machine] active state representation to a human readable
/// string. An uml state machine can be a hierarchy of state machine due
/// to implementing compound state regions with child state machines, the active
/// state of the machine is not represented by a single state identifier but a
/// hierarchic array of active state. Example:
/// ```
/// [StateID.s2,[SubStateID.s1,[SubSubStateID.s1],[SubSubStateID.work]],
/// [SubStateID.s1,[SubSubStateID.s1,[SubSubStateID.s1],[SubSubStateID.work],
/// [SubSubStateID.work],],[SubSubStateID.s1,[SubSubStateID.s1],
/// [SubSubStateID.work],]],[SubStateID.s1,[SubSubStateID.s1],
/// [SubSubStateID.work]]];
/// ```
/// is converted to a string by this function:
/// ```
/// StateID.s2
///     ├─SubStateID.s1
///     │   ├─SubSubStateID.s1
///     │   └─SubSubStateID.s1
///     ├─SubStateID.s1
///     │   ├─SubSubStateID.s1
///     │   │   ├─SubSubStateID.s1
///     │   │   ├─SubSubStateID.s1
///     │   │   └─SubSubStateID.s1
///     │   └─SubSubStateID.s1
///     │       ├─SubSubStateID.s1
///     │       └─SubSubStateID.s1
///     └─SubStateID.s1
///         ├─SubSubStateID.s1
///         └─SubSubStateID.s1
/// ```
/// [activeState] activeState as a hierarchical array to be converted
/// [tab] Only used for recursive invocation. It is the line tabulator.
/// [last] true indicates that item is the last on at its hierarchy level. It
/// is used to decide on how to draw tabulation.
String pretty(
  List<dynamic> activeState, {
  String tab = '',
  bool last = true,
}) {
  var str = '';
  var localTab = tab;
  const sectionSpaces = '   ';
  for (final element in activeState) {
    if (element is List) {
      localTab = '$localTab${last ? ' ' : '│'}$sectionSpaces';

      str += pretty(element, tab: localTab, last: element == activeState.last);
      localTab =
          localTab.substring(0, localTab.length - sectionSpaces.length - 1);
    } else {
      str = '$tab${tab.isEmpty ? '' : last ? '└─' : '├─'}$element\n';
    }
  }

  return str;
}
