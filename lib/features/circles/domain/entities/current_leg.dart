class CurrentLeg {
  const CurrentLeg({required this.mode, required this.label});

  /// Provider-specific mode values are resolved by the routing spike.
  final String mode;
  final String label;
}
