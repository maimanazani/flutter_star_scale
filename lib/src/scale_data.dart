import 'package:flutter_star_scale/flutter_star_scale.dart';

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
      case 'INVALID':
      default:
        return ScaleDataType.INVALID;
    }
  }

  ScaleDataStatus? _getStatusFromString(String status) {
    switch (status) {
      case 'ERROR':
        return ScaleDataStatus.ERROR;
      case 'STABLE':
        return ScaleDataStatus.STABLE;
      case 'UNSTABLE':
        return ScaleDataStatus.UNSTABLE;
      case 'INVALID':
      default:
        return ScaleDataStatus.INVALID;
    }
  }
}

class UpdateScaleSetting {
  ScaleDataUpdateSettingStatus? status;
  ScaleDataUpdateSettingResponse? response;

  UpdateScaleSetting(dynamic data) {
    if (data.containsKey('status')) {
      String statusString = data['status'];
      status = _getStatusFromString(statusString);
    }
    if (data.containsKey('type')) {
      String statusString = data['type'];
      response = _getResponseFromString(statusString);
    }
  }

  ScaleDataUpdateSettingStatus? _getStatusFromString(String status) {
    switch (status) {
      case 'LOADING':
        return ScaleDataUpdateSettingStatus.LOADING;
      case 'LOADED':
        return ScaleDataUpdateSettingStatus.LOADED;
      case 'INITIAL':
      default:
        return ScaleDataUpdateSettingStatus.INITIAL;
    }
  }

  ScaleDataUpdateSettingResponse? _getResponseFromString(String response) {
    switch (response) {
      case 'UPDATE_SETTING_SUCCESS':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_SUCCESS;
      case 'UPDATE_SETTING_NOT_CONNECTED':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_NOT_CONNECTED;
      case 'UPDATE_SETTING_REQUEST_REJECTED':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_REQUEST_REJECTED;
      case 'UPDATE_SETTING_TIMEOUT':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_TIMEOUT;
      case 'UPDATE_SETTING_ALREADY_EXECUTING':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_ALREADY_EXECUTING;
      case 'UPDATE_SETTING_UNEXPECTED_ERROR':
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_UNEXPECTED_ERROR;
      case 'UPDATE_SETTING_NOT_SUPPORTED':
      default:
        return ScaleDataUpdateSettingResponse.UPDATE_SETTING_NOT_SUPPORTED;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status?.name,
      'response': response?.name,
    };
  }
}

class Scale {
  ScaleStatus? status;
  String? msg;

  WeightData? weightData;
  UpdateScaleSetting? updateScaleSetting;

  Scale(dynamic data) {
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

    if (data.containsKey('scale_update_setting')) {
      updateScaleSetting = UpdateScaleSetting(data['scale_update_setting']);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'weight_data': weightData?.toMap(),
      'scale_update_setting': updateScaleSetting?.toMap(),
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
