package com.example.self_improve_app

import android.app.ActivityManager
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class BlockOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var blockedPackageName: String? = null
    private val TAG = "BlockOverlayService"

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        blockedPackageName = intent?.getStringExtra("packageName") ?: "Unknown App"
        Log.d(TAG, "Blocking app: $blockedPackageName")

        // Always show/update overlay when requested
        if (overlayView == null) {
            Log.d(TAG, "Showing blocking overlay")
            showOverlay(blockedPackageName!!)
        } else {
            // Update existing overlay with new package name
            Log.d(TAG, "Updating existing overlay")
            updateOverlay(blockedPackageName!!)
        }

        return START_STICKY
    }

    private fun showOverlay(packageName: String) {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        // Inflate the overlay layout
        val inflater = LayoutInflater.from(this)
        overlayView = inflater.inflate(R.layout.block_overlay, null)

        // Set up the layout parameters
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            // Block all touches to underlying app - removed FLAG_NOT_TOUCH_MODAL
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.CENTER

        // Add the view to the window
        windowManager?.addView(overlayView, params)

        // Set up close button - force close app and hide overlay
        overlayView?.findViewById<Button>(R.id.btn_close)?.setOnClickListener {
            Log.d(TAG, "Close button clicked - force closing app and hiding overlay")
            blockedPackageName?.let { forceCloseApp(it) }
            dismissOverlay()
        }

        // Set up go back button - force close app and return to home screen
        overlayView?.findViewById<Button>(R.id.btn_go_back)?.setOnClickListener {
            Log.d(TAG, "Go back button clicked - force closing app and hiding overlay")
            blockedPackageName?.let { forceCloseApp(it) }
            dismissOverlay()
        }

        // Display app name
        overlayView?.findViewById<TextView>(R.id.tv_app_name)?.text =
            "This app is blocked during focus time"

        Log.d(TAG, "Overlay displayed successfully")
    }

    private fun updateOverlay(packageName: String) {
        overlayView?.findViewById<TextView>(R.id.tv_app_name)?.text =
            "This app is blocked during focus time"
        blockedPackageName = packageName
    }

    private fun forceCloseApp(packageName: String) {
        try {
            val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            activityManager.killBackgroundProcesses(packageName)
            Log.d(TAG, "Force closed app: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Error force closing app: $e")
        }
    }

    private fun removeOverlay() {
        if (overlayView != null) {
            Log.d(TAG, "Removing overlay")
            windowManager?.removeView(overlayView)
            overlayView = null
        }
    }

    private fun dismissOverlay() {
        removeOverlay()
        // Notify Flutter that overlay was dismissed
        MainActivity.notifyOverlayDismissed()
        // Go to home screen
        val homeIntent = Intent(Intent.ACTION_MAIN)
        homeIntent.addCategory(Intent.CATEGORY_HOME)
        homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(homeIntent)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        removeOverlay()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        Log.d(TAG, "Task removed")
        // Don't stop the service when task is removed
    }
}
