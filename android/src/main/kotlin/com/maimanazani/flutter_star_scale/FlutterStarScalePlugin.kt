package com.maimanazani.flutter_star_scale

import android.content.Context
import android.graphics.*
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import io.flutter.plugin.common.EventChannel

import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.nio.charset.Charset
import java.nio.charset.UnsupportedCharsetException
import android.webkit.URLUtil
import com.starmicronics.starmgsio.ConnectionInfo;
import com.starmicronics.starmgsio.Scale;
import com.starmicronics.starmgsio.ScaleCallback;
import com.starmicronics.starmgsio.ScaleData;
import com.starmicronics.starmgsio.ScaleOutputConditionSetting;
import com.starmicronics.starmgsio.ScaleSetting;
import com.starmicronics.starmgsio.ScaleType;
import com.starmicronics.starmgsio.StarDeviceManager;

/** FlutterStarScalePlugin */
class FlutterStarScalePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private var mScale: Scale? = null
    private var eventSink: EventChannel.EventSink? = null

    private val data: MutableMap<String, Any> = mutableMapOf(
        "status" to "online",
        "date" to System.currentTimeMillis(), // Initial date
        "unit" to "default_unit",
        "msg" to ""
    )

    companion object {
        private const val CHANNEL = "flutter_star_scale"
        private const val EVENT_CHANNEL = "flutter_star_scale/events"
        private lateinit var applicationContext: Context

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            channel.setMethodCallHandler(FlutterStarScalePlugin())
            setupPlugin(registrar.messenger(), registrar.context())
        }

        @JvmStatic
        fun setupPlugin(messenger: BinaryMessenger, context: Context) {
            try {
                applicationContext = context.applicationContext
                val channel = MethodChannel(messenger, CHANNEL)
                channel.setMethodCallHandler(FlutterStarScalePlugin())

                val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
                eventChannel.setStreamHandler(FlutterStarScalePlugin())
            } catch (e: Exception) {
                Log.e("FlutterStarScalePlugin", "Registration failed", e)
            }
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(
            flutterPluginBinding.flutterEngine.dartExecutor,
            CHANNEL
        )
        channel.setMethodCallHandler(FlutterStarScalePlugin())
        setupPlugin(
            flutterPluginBinding.flutterEngine.dartExecutor,
            flutterPluginBinding.applicationContext
        )
        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mScale?.let { scale ->
            scale.disconnect()
        }
        eventSink = null
    }

    inner class MethodRunner(call: MethodCall, result: Result) : Runnable {
        private val call: MethodCall = call
        private val result: Result = result

        override fun run() {
            when (call.method) {
                "startScan" -> {
                    scanForScales(call, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val methodResultWrapper = MethodResultWrapper(result)
        Thread(MethodRunner(call, methodResultWrapper)).start()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startReadingData(arguments)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null

    }

    class MethodResultWrapper(methodResult: Result) : Result {

        private val methodResult: Result = methodResult
        private val handler: Handler = Handler(Looper.getMainLooper())

        public override fun success(result: Any?) {
            handler.post(object : Runnable {
                override fun run() {
                    methodResult.success(result)
                }
            })
        }

        public override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post(object : Runnable {
                override fun run() {
                    methodResult.error(errorCode, errorMessage, errorDetails)
                }
            })
        }

        public override fun notImplemented() {
            handler.post(object : Runnable {
                override fun run() {
                    methodResult.notImplemented()
                }
            })
        }
    }

    private fun startReadingData(arguments: Any?) {
        val params = arguments as? Map<*, *>
        val interfaceType = params?.get("INTERFACE_TYPE_KEY") as? String
        val macAddress = params?.get("IDENTIFIER_KEY") as? String

        // val handler = Handler(Looper.getMainLooper())
        // handler.postDelayed(object : Runnable {
        //     override fun run() {
        //         data["date"] = System.currentTimeMillis()

        //         // Send the map to the Flutter side
        //         eventSink?.success(data)
        //         handler.postDelayed(this, 1000) // Send data every second
        //     }
        // }, 1000)

        if (mScale == null) {
            val starDeviceManager = StarDeviceManager(applicationContext);

            val connectionInfo = when (interfaceType) {
                "BluetoothLowEnergy" -> {
                    ConnectionInfo.Builder()
                        .setBleInfo(macAddress)
                        .build()
                }

                "USB" -> {
                    ConnectionInfo.Builder()
                        .setUsbInfo(macAddress)
                        .setBaudRate(1200)
                        .build()
                }

                else -> {
                    ConnectionInfo.Builder()
                        .setBleInfo(macAddress)
                        .build()
                }
            }

            mScale = starDeviceManager.createScale(connectionInfo)
            mScale?.connect(mScaleCallback)
        }
    }


    public fun scanForScales(@NonNull call: MethodCall, @NonNull result: Result) {
        val strInterface: String = call.argument<String>("type") as String
        val response: MutableList<Map<String, String>> = mutableListOf()


        try {
            val interfaceType = when (strInterface) {
                "BluetoothLowEnergy" -> StarDeviceManager.InterfaceType.BluetoothLowEnergy
                "USB" -> StarDeviceManager.InterfaceType.USB
                else -> StarDeviceManager.InterfaceType.All
            }
            // val item = mutableMapOf<String, String>()
            // item["INTERFACE_TYPE_KEY"] = "BLE"
            // item["DEVICE_NAME_KEY"] = "Scale-4502-a12"
            // item["IDENTIFIER_KEY"] = "62:00:A1:27:99:FC"
            // item["SCALE_TYPE_KEY"] = "MGTS"

            // response.add(item)
            // result.success(response)

            val starDeviceManager =
                StarDeviceManager(applicationContext, interfaceType)

            starDeviceManager.scanForScales(
                object : StarDeviceManagerCallback() {
                    override fun onDiscoverScale(@NonNull connectionInfo: ConnectionInfo) {
                        val item = mutableMapOf<String, String>()
                        item["INTERFACE_TYPE_KEY"] = connectionInfo.interfaceType.name
                        item["DEVICE_NAME_KEY"] = connectionInfo.deviceName
                        item["IDENTIFIER_KEY"] = connectionInfo.identifier
                        item["SCALE_TYPE_KEY"] = connectionInfo.getScaleType().name()
                        response.add(item)
                        result.success(response)
                    }
                })

        } catch (e: Exception) {
            result.error("PORT_DISCOVERY_ERROR", e.message, null)

        }
    }

    private val mScaleCallback = object : ScaleCallback() {
        override fun onConnect(scale: Scale, status: Int) {
            var connectSuccess = false

            when (status) {
                Scale.CONNECT_SUCCESS -> {
                    connectSuccess = true
                    data["msg"] = "Connect success."
                }

                Scale.CONNECT_NOT_AVAILABLE -> {
                    data["msg"] = "Failed to connect. (Not available)"
                }

                Scale.CONNECT_ALREADY_CONNECTED -> {
                    data["msg"] = "Failed to connect. (Already connected)"
                }

                Scale.CONNECT_TIMEOUT -> {
                    data["msg"] = "Failed to connect. (Timeout)"
                }

                Scale.CONNECT_READ_WRITE_ERROR -> {
                    data["msg"] = "Failed to connect. (Read Write error)"
                }

                Scale.CONNECT_NOT_SUPPORTED -> {
                    data["msg"] = "Failed to connect. (Not supported device)"
                }

                Scale.CONNECT_NOT_GRANTED_PERMISSION -> {
                    data["msg"] = "Failed to connect. (Not granted permission)"
                }

                else -> {
                    data["msg"] = "Failed to connect. (Unexpected error)"

                }
            }
            eventSink?.success(data)
            if (!connectSuccess) {
                mScale = null

            }
        }

        override fun onDisconnect(scale: Scale, status: Int) {
            mScale = null

            when (status) {
                Scale.DISCONNECT_SUCCESS -> {
                    //result.success("Disconnect success.")
                }

                Scale.DISCONNECT_NOT_CONNECTED -> {
                    // result.success("Failed to disconnect. (Not connected)")
                }

                Scale.DISCONNECT_TIMEOUT -> {
                    // result.success("Failed to disconnect. (Timeout)")
                }

                Scale.DISCONNECT_READ_WRITE_ERROR -> {
                    //result.success("Failed to disconnect. (Read Write error)")
                }

                Scale.DISCONNECT_UNEXPECTED_ERROR -> {
                    // result.success("Failed to disconnect. (Unexpected error)")
                }

                else -> {
                    // result.success("Unexpected disconnection.")
                }
            }
        }
    }


}
