package com.example.step_detector

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.step_detector/widget"
    private var pendingWorkoutMode = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            if (call.method == "checkWidgetLaunch") {
                result.success(pendingWorkoutMode)
                pendingWorkoutMode = false
            } else {
                result.notImplemented()
            }
        }
        
        // Handle initial intent if app was launched from widget
        if (intent?.action == "SWITCH_TO_WORKOUT_MODE") {
            pendingWorkoutMode = true
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == "SWITCH_TO_WORKOUT_MODE") {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL).invokeMethod("switchToWorkoutMode", null)
            }
        }
    }
}
