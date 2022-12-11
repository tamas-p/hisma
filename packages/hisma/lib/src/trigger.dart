/// This class represents the transition that is unique as it
/// happens from state A to state B at E event when its guard
/// and priority selects it from the list of transitions on E.
class Trigger<S, E, T> {
  Trigger({
    required this.source,
    required this.event,
    required this.transition,
  });

  factory Trigger.entryPoint({required S source}) => Trigger(
        source: source,
        event: null,
        transition: null,
      );

  final S? source;
  final E? event;
  final T? transition;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trigger<S, E, T> &&
        other.source == source &&
        other.event == event &&
        other.transition == transition;
  }

  @override
  int get hashCode => source.hashCode ^ event.hashCode ^ transition.hashCode;
}
