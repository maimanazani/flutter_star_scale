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

enum ScaleStatus {
  connect_success,
  connect_failed,
  disconnect_success,
  disconnect_failed
}

enum ScaleDataStatus { INVALID, STABLE, UNSTABLE, ERROR }

enum ScaleDataType {
  INVALID,
  NET_NOT_TARED,
  NET,
  TARE,
  PRESET_TARE,
  TOTAL,
  UNIT,
  GROSS
}

enum ScaleDataUpdateSettingStatus {
  INITIAL,
  LOADING,
  LOADED,
}

enum ScaleDataUpdateSettingResponse {
  UPDATE_SETTING_SUCCESS,
  UPDATE_SETTING_NOT_CONNECTED,
  UPDATE_SETTING_REQUEST_REJECTED,
  UPDATE_SETTING_TIMEOUT,
  UPDATE_SETTING_ALREADY_EXECUTING,
  UPDATE_SETTING_UNEXPECTED_ERROR,
  UPDATE_SETTING_NOT_SUPPORTED
}
