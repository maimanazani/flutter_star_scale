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
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException
import java.nio.charset.Charset
import java.nio.charset.UnsupportedCharsetException
import android.webkit.URLUtil
import com.starmicronics.starmgsio.StarDeviceManager
import com.starmicronics.starmgsio.StarDeviceManagerCallback
import com.starmicronics.starmgsio.ConnectionInfo

/** FlutterStarScalePlugin */
class FlutterStarScalePlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val CHANNEL = "flutter_star_scale"
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
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Cleanup if necessary
    }

    inner class MethodRunner(call: MethodCall, result: Result) : Runnable {
        private val call: MethodCall = call
        private val result: Result = result

        override fun run() {
            when (call.method) {
                "scanForScales" -> {
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

    public fun scanForScales(@NonNull call: MethodCall, @NonNull result: Result) {
        val strInterface: String = call.argument<String>("type") as String
        val response: MutableList<Map<String, String>> = mutableListOf()
        try {
            val starDeviceManager =
                StarDeviceManager(
                    applicationContext,
                    StarDeviceManager.InterfaceType.All
                )

            starDeviceManager.scanForScales(object : StarDeviceManagerCallback() {
                override fun onDiscoverScale(@NonNull connectionInfo: ConnectionInfo) {
                    val item = mutableMapOf<String, String>()
                    item["INTERFACE_TYPE_KEY"] = connectionInfo.interfaceType.name
                    item["DEVICE_NAME_KEY"] = connectionInfo.deviceName
                    item["IDENTIFIER_KEY"] = connectionInfo.identifier

                    response.add(item)
                    result.success("test response")
                }

            })

 

        } catch (e: Exception) {
            // result.error("PORT_DISCOVERY_ERROR", e.message, null)
            result.success(e.message)

        }
    }


}
