enum ScaleStatus {
  connect_success,
  connect_failed,
  disconnect_success,
  disconnect_failed
}

class ScaleData {
  ScaleStatus? status;
  String? msg;

  ScaleData(dynamic data) {
    if (data.containsKey('status')) {
      String statusString = data['status'];
      status = _getStatusFromString(statusString);
    }
    if (data.containsKey('msg')) {
      msg = data['msg'];
    }
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
