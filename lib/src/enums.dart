///Enum for Star Port type
enum StarInterfaceType {
  /// checks all
  All,

  /// Checks bluetooth
  BluetoothLowEnergy,

  /// Checks USB
  USB,
}

///Converts enum to String
extension ExtendedPortype on StarInterfaceType {
  String get text {
    return toString().split('.').last;
  }
}
