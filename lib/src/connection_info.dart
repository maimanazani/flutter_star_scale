class ConnectionInfo {
  /// Interface Type
  String? interfaceTypeKey;

  /// Scale Name
  String? deviceNameKey;

  /// Identifier Key
  String? identifierKey;

  /// Scale Type
  String? scaleTypeKey;

  ConnectionInfo(dynamic connectionInfo) {
    if (connectionInfo.containsKey('INTERFACE_TYPE_KEY')) {
      interfaceTypeKey = connectionInfo['INTERFACE_TYPE_KEY'];
    }
    if (connectionInfo.containsKey('DEVICE_NAME_KEY')) {
      deviceNameKey = connectionInfo['DEVICE_NAME_KEY'];
    }
    if (connectionInfo.containsKey('IDENTIFIER_KEY')) {
      identifierKey = connectionInfo['IDENTIFIER_KEY'];
    }
    if (connectionInfo.containsKey('SCALE_TYPE_KEY')) {
      scaleTypeKey = connectionInfo['SCALE_TYPE_KEY'];
    }
  }

  /// Converts the ConnectionInfo object to a Map
  Map<String, String?> toMap() {
    return {
      'INTERFACE_TYPE_KEY': interfaceTypeKey,
      'DEVICE_NAME_KEY': deviceNameKey,
      'IDENTIFIER_KEY': identifierKey,
      'SCALE_TYPE_KEY': scaleTypeKey,
    };
  }
}
