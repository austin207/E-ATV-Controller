class ControllerState {
  final Map<String, bool> arrowStates;
  final double speed;
  final bool boostActive;
  final double capacitorCharge;
  final bool lightsOn;
  final bool emergencyStop;

  ControllerState({
    required this.arrowStates,
    required this.speed,
    required this.boostActive,
    required this.capacitorCharge,
    required this.lightsOn,
    required this.emergencyStop,
  });

  ControllerState copyWith({
    Map<String, bool>? arrowStates,
    double? speed,
    bool? boostActive,
    double? capacitorCharge,
    bool? lightsOn,
    bool? emergencyStop,
  }) {
    return ControllerState(
      arrowStates: arrowStates ?? this.arrowStates,
      speed: speed ?? this.speed,
      boostActive: boostActive ?? this.boostActive,
      capacitorCharge: capacitorCharge ?? this.capacitorCharge,
      lightsOn: lightsOn ?? this.lightsOn,
      emergencyStop: emergencyStop ?? this.emergencyStop,
    );
  }
}
