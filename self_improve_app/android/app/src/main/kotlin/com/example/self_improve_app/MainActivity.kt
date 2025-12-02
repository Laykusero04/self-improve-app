package com.example.self_improve_app

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app_blocker"

    companion object {
        private var methodChannel: MethodChannel? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        fun notifyOverlayDismissed() {
            mainHandler.post {
                methodChannel?.invokeMethod("onOverlayDismissed", null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "showBlockOverlay" -> {
                    val packageName = call.argument<String>("packageName")
                    showBlockOverlay(packageName)
                    result.success(true)
                }
                "stopBlockOverlay" -> {
                    stopBlockOverlay()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun showBlockOverlay(packageName: String?) {
        val intent = Intent(this, BlockOverlayService::class.java)
        intent.putExtra("packageName", packageName)
        startService(intent)
    }

    private fun stopBlockOverlay() {
        val intent = Intent(this, BlockOverlayService::class.java)
        stopService(intent)
    }
}
