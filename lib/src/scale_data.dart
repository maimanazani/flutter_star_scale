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

class WeightData {
  String? unit;
  double? weight;
  ScaleDataStatus? status;
  ScaleDataType? type;

  WeightData(dynamic data) {
    if (data.containsKey('unit')) {
      unit = data['unit'];
    }
    if (data.containsKey('weight')) {
      weight = data['weight'];
    }
    if (data.containsKey('status')) {
      String statusString = data['status'];
      status = _getStatusFromString(statusString);
    }
    if (data.containsKey('type')) {
      String statusString = data['type'];
      type = _getTypeFromString(statusString);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'weight': weight,
      'status': status?.name,
      'type': type?.name,
    };
  }

  ScaleDataType? _getTypeFromString(String type) {
    switch (type) {
      case 'INVALID':
        return ScaleDataType.INVALID;
      case 'NET_NOT_TARED':
        return ScaleDataType.NET_NOT_TARED;
      case 'NET':
        return ScaleDataType.NET;
      case 'TARE':
        return ScaleDataType.TARE;
      case 'PRESET_TARE':
        return ScaleDataType.PRESET_TARE;
      case 'GROSS':
        return ScaleDataType.GROSS;
      case 'TOTAL':
        return ScaleDataType.TOTAL;
      case 'UNIT':
        return ScaleDataType.UNIT;
      default:
        return ScaleDataType.INVALID;
    }
  }

  ScaleDataStatus? _getStatusFromString(String status) {
    switch (status) {
      case 'ERROR':
        return ScaleDataStatus.ERROR;
      case 'INVALID':
        return ScaleDataStatus.INVALID;
      case 'STABLE':
        return ScaleDataStatus.STABLE;
      case 'UNSTABLE':
        return ScaleDataStatus.UNSTABLE;
      default:
        return ScaleDataStatus.INVALID;
    }
  }
}

class ScaleData {
  ScaleStatus? status;
  String? msg;

  WeightData? weightData;

  ScaleData(dynamic data) {
    if (data.containsKey('status')) {
      String statusString = data['status'];
      status = _getStatusFromString(statusString);
    }
    if (data.containsKey('msg')) {
      msg = data['msg'];
    }

    if (data.containsKey('weight_data')) {
      weightData = WeightData(data['weight_data']);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'weight_data': weightData?.toMap(),
    };
  }

  ScaleStatus? _getStatusFromString(String status) {
    switch (status) {
      case 'connect_success':
        return ScaleStatus.connect_success;
      case 'connect_failed':
        return ScaleStatus.connect_failed;
      case 'disconnect_success':
        return ScaleStatus.disconnect_success;
      case 'disconnect_failed':
        return ScaleStatus.disconnect_failed;
      default:
        return null;
    }
  }
}
