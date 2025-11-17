package com.example.self_improve_app

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
    private val TAG = "BlockOverlayService"

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val packageName = intent?.getStringExtra("packageName") ?: "Unknown App"
        Log.d(TAG, "Blocking app: $packageName")

        // Only show overlay if not already showing
        if (overlayView == null) {
            Log.d(TAG, "Showing blocking overlay")
            showOverlay(packageName)
        } else {
            Log.d(TAG, "Overlay already showing")
        }

        // Don't auto-hide - let user dismiss manually
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
            // Make overlay focusable and block touches to underlying app
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.CENTER

        // Add the view to the window
        windowManager?.addView(overlayView, params)

        // Set up close button - just hide overlay, DON'T stop service
        overlayView?.findViewById<Button>(R.id.btn_close)?.setOnClickListener {
            Log.d(TAG, "Close button clicked - hiding overlay but keeping service alive")
            removeOverlay()
            // Go to home screen
            val homeIntent = Intent(Intent.ACTION_MAIN)
            homeIntent.addCategory(Intent.CATEGORY_HOME)
            homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(homeIntent)
            // DON'T call stopSelf() - let Flutter manage the service lifecycle
        }

        // Set up go back button - returns to home screen
        overlayView?.findViewById<Button>(R.id.btn_go_back)?.setOnClickListener {
            Log.d(TAG, "Go back button clicked - hiding overlay but keeping service alive")
            removeOverlay()
            // Go to home screen
            val homeIntent = Intent(Intent.ACTION_MAIN)
            homeIntent.addCategory(Intent.CATEGORY_HOME)
            homeIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(homeIntent)
            // DON'T call stopSelf() - let Flutter manage the service lifecycle
        }

        // Display app name
        overlayView?.findViewById<TextView>(R.id.tv_app_name)?.text =
            "This app is blocked during focus time"

        Log.d(TAG, "Overlay displayed successfully")
    }

    private fun removeOverlay() {
        if (overlayView != null) {
            Log.d(TAG, "Removing overlay")
            windowManager?.removeView(overlayView)
            overlayView = null
        }
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
