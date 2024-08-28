enum ScaleStatus {
  connect_success,
  connect_failed,
  disconnect_success,
  disconnect_failed
}

class WeightData {
  String? unit;
  double? weight;

  WeightData(dynamic data) {
    if (data.containsKey('unit')) {
      unit = data['unit'];
    }
    if (data.containsKey('weight')) {
      weight = data['weight'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'weight': weight,
    };
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
        return null; // or handle the unknown case as needed
    }
  }
}
