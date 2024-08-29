package com.maimanazani.flutter_star_scale;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.starmicronics.starmgsio.ConnectionInfo;
import com.starmicronics.starmgsio.Scale;
import com.starmicronics.starmgsio.ScaleCallback;
import com.starmicronics.starmgsio.ScaleData;
import com.starmicronics.starmgsio.ScaleOutputConditionSetting;
import com.starmicronics.starmgsio.ScaleSetting;
import com.starmicronics.starmgsio.ScaleType;
import com.starmicronics.starmgsio.StarDeviceManager;
import com.starmicronics.starmgsio.StarDeviceManagerCallback;

public class FlutterStarScalePlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private static final String CHANNEL = "flutter_star_scale";
    private static final String EVENT_CHANNEL = "flutter_star_scale/events";
    private MethodChannel methodChannel;
    private Scale mScale = null;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private static Context applicationContext;

    Map<String, Object> scaleUpdateSetting = new HashMap<String, Object>() {{
        put("status", "INITIAL");
        put("response", "UPDATE_SETTING_NOT_SUPPORTED");
    }};

    Map<String, Object> scaleWeight = new HashMap<String, Object>() {{
        put("unit", "lbs");
        put("weight", 0.00);
        put("status", "INVALID");
        put("type", "INVALID");
    }};
    private final Map<String, Object> data = new HashMap<String, Object>() {{
        put("status", "");
        put("msg", "");
        put("weight_data", scaleWeight);
        put("scale_update_setting", scaleUpdateSetting);
    }};


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
        // Trigger event whenever required
        handleEvent(arguments);
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("startScan")) {
            scanForScales(call, result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
    }

    private void handleEvent(Object arguments) {
        if (arguments instanceof Map) {
            Map<?, ?> params = (Map<?, ?>) arguments;
            String interfaceType = (String) params.get("INTERFACE_TYPE_KEY");
            String macAddress = (String) params.get("IDENTIFIER_KEY");
            String action = (String) params.get("action");

            if ("connect".equals(action)) {
                if (macAddress != null && mScale == null) {
                    StarDeviceManager starDeviceManager = new StarDeviceManager(applicationContext);

                    ConnectionInfo connectionInfo = null;
                    if ("BluetoothLowEnergy".equals(interfaceType)) {
                        connectionInfo = new ConnectionInfo.Builder()
                                .setBleInfo(macAddress)
                                .build();
                    } else if ("USB".equals(interfaceType)) {
                        connectionInfo = new ConnectionInfo.Builder()
                                .setUsbInfo(macAddress)
                                .setBaudRate(1200)
                                .build();
                    } else {
                        connectionInfo = new ConnectionInfo.Builder()
                                .setBleInfo(macAddress)
                                .build();
                    }

                    mScale = starDeviceManager.createScale(connectionInfo);
                    mScale.connect(mScaleCallback);
                }

            } else if ("disconnect".equals(action)) {
                if (mScale != null) {
                    mScale.disconnect();
                }
            } else if ("tare".equals(action)) {
                if (mScale != null) {
                    Map<String, Object> setting = (Map<String, Object>) data.get("scale_update_setting");
                    setting.put("status", "LOADING");
                    eventSink.success(data);
                    mScale.updateSetting(ScaleSetting.ZeroPointAdjustment);
                }
            }
        }
    }

    public void scanForScales(@NonNull MethodCall call, @NonNull Result result) {
        String strInterface = call.argument("type");
        final Map<String, String> response = new HashMap<>();

        try {
            StarDeviceManager.InterfaceType interfaceType;
            if ("BluetoothLowEnergy".equals(strInterface)) {
                interfaceType = StarDeviceManager.InterfaceType.BluetoothLowEnergy;
            } else if ("USB".equals(strInterface)) {
                interfaceType = StarDeviceManager.InterfaceType.USB;
            } else {
                interfaceType = StarDeviceManager.InterfaceType.All;
            }
            // List<Map<String, String>> responseList = new ArrayList<>();

            // Map<String, String> item = new HashMap<>();
            // item.put("INTERFACE_TYPE_KEY", "BLE");
            // item.put("DEVICE_NAME_KEY", "Scale-4502-a12");
            // item.put("IDENTIFIER_KEY", "62:00:A1:27:99:FC");
            // item.put("SCALE_TYPE_KEY", "MGTS");
            // responseList.add(item);
            // result.success(responseList);
            StarDeviceManager starDeviceManager = new StarDeviceManager(applicationContext, interfaceType);

            starDeviceManager.scanForScales(new StarDeviceManagerCallback() {
                @Override
                public void onDiscoverScale(@NonNull ConnectionInfo connectionInfo) {
                    List<Map<String, String>> responseList = new ArrayList<>();
                    Map<String, String> item = new HashMap<>();
                    item.put("INTERFACE_TYPE_KEY", connectionInfo.getInterfaceType().name());
                    item.put("DEVICE_NAME_KEY", connectionInfo.getDeviceName());
                    item.put("IDENTIFIER_KEY", connectionInfo.getIdentifier());
                    item.put("SCALE_TYPE_KEY", connectionInfo.getScaleType().name());
                    responseList.add(item);
                    result.success(responseList);
                }
            });

        } catch (Exception e) {
            result.error("PORT_DISCOVERY_ERROR", e.getMessage(), null);
        }
    }


    private final ScaleCallback mScaleCallback = new ScaleCallback() {
        @Override
        public void onConnect(Scale scale, int status) {
            boolean connectSuccess = false;

            switch (status) {
                case Scale.CONNECT_SUCCESS:
                    connectSuccess = true;
                    data.put("msg", "Connect success.");
                    data.put("status", "connect_success");
                    break;

                case Scale.CONNECT_NOT_AVAILABLE:
                    data.put("msg", "Failed to connect. (Not available)");
                    data.put("status", "connect_failed");
                    break;

                case Scale.CONNECT_ALREADY_CONNECTED:
                    data.put("msg", "Failed to connect. (Already connected)");
                    data.put("status", "connect_failed");
                    break;

                case Scale.CONNECT_TIMEOUT:
                    data.put("msg", "Failed to connect. (Timeout)");
                    data.put("status", "connect_failed");
                    break;

                case Scale.CONNECT_READ_WRITE_ERROR:
                    data.put("msg", "Failed to connect. (Read Write error)");
                    data.put("status", "connect_failed");
                    break;

                case Scale.CONNECT_NOT_SUPPORTED:
                    data.put("msg", "Failed to connect. (Not supported device)");
                    data.put("status", "connect_failed");
                    break;

                case Scale.CONNECT_NOT_GRANTED_PERMISSION:
                    data.put("msg", "Failed to connect. (Not granted permission)");
                    data.put("status", "connect_failed");
                    break;

                default:
                    data.put("msg", "Failed to connect. (Unexpected error)");
                    data.put("status", "connect_failed");
                    break;
            }

            if (eventSink != null) {
                eventSink.success(data);
            }

            if (!connectSuccess) {
                mScale = null;
            }
        }

        @Override
        public void onDisconnect(Scale scale, int status) {
            mScale = null;

            switch (status) {
                case Scale.DISCONNECT_SUCCESS:
                    data.put("msg", "Disconnect success.");
                    data.put("status", "disconnect_success");
                    break;

                case Scale.DISCONNECT_NOT_CONNECTED:
                    data.put("msg", "Failed to disconnect. (Not connected)");
                    data.put("status", "disconnect_failed");
                    break;

                case Scale.DISCONNECT_TIMEOUT:
                    data.put("msg", "Failed to disconnect. (Timeout)");
                    data.put("status", "disconnect_failed");
                    break;

                case Scale.DISCONNECT_READ_WRITE_ERROR:
                    data.put("msg", "Failed to disconnect. (Read Write error)");
                    data.put("status", "disconnect_failed");
                    break;

                case Scale.DISCONNECT_UNEXPECTED_ERROR:
                    data.put("msg", "Failed to disconnect. (Unexpected error)");
                    data.put("status", "disconnect_failed");
                    break;

                default:
                    data.put("msg", "Unexpected disconnection.");
                    data.put("status", "disconnect_success");
                    break;
            }
            if (eventSink != null) {
                eventSink.success(data);
            }
        }

        @Override
        public void onReadScaleData(Scale scale, ScaleData scaleData) {

            if (mScale != null && eventSink != null) {
                Map<String, Object> weightData = (Map<String, Object>) data.get("weight_data");

                Double prev = (Double) weightData.get("weight");

                double cur = scaleData.getWeight();
                String unit = scaleData.getUnit().toString();
                String status = scaleData.getStatus().toString();
                String type = scaleData.getDataType().toString();


                if (prev == null || prev != cur) {
                    weightData.put("weight", cur);
                    weightData.put("unit", unit);
                    weightData.put("status", status);
                    weightData.put("type", type);

                    if (eventSink != null) {
                        eventSink.success(data);
                    }
                }

            }
        }

        @Override
        public void onUpdateSetting(Scale scale, ScaleSetting scaleSetting, int status) {
            Map<String, Object> setting = (Map<String, Object>) data.get("scale_update_setting");

            if (scaleSetting == ScaleSetting.ZeroPointAdjustment) {
                switch (status) {
                    case Scale.UPDATE_SETTING_SUCCESS:
                        setting.put("response", "UPDATE_SETTING_SUCCESS");
                        break;
                    case Scale.UPDATE_SETTING_NOT_CONNECTED:
                        setting.put("response", "UPDATE_SETTING_NOT_CONNECTED");
                        break;
                    case Scale.UPDATE_SETTING_REQUEST_REJECTED:
                        setting.put("response", "UPDATE_SETTING_REQUEST_REJECTED");
                        break;
                    case Scale.UPDATE_SETTING_TIMEOUT:
                        setting.put("response", "UPDATE_SETTING_TIMEOUT");
                        break;
                    case Scale.UPDATE_SETTING_ALREADY_EXECUTING:
                        setting.put("response", "UPDATE_SETTING_ALREADY_EXECUTING");
                        break;
                    case Scale.UPDATE_SETTING_UNEXPECTED_ERROR:
                        setting.put("response", "UPDATE_SETTING_UNEXPECTED_ERROR");
                        break;
                    case Scale.UPDATE_SETTING_NOT_SUPPORTED:
                        setting.put("response", "UPDATE_SETTING_NOT_SUPPORTED");
                        break;
                    default:
                        setting.put("response", "UPDATE_SETTING_NOT_SUPPORTED");
                        break;
                }
            }
            setting.put("status", "LOADED");

            if (eventSink != null) {
                eventSink.success(data);
            }
        }

    };
} 