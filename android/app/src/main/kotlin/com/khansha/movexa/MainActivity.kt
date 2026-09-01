package com.khansha.movexa

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.khansha.movexa/widget"
    private var pendingAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            if (call.method == "checkWidgetLaunch") {
                result.success(pendingAction)
                pendingAction = null
            } else {
                result.notImplemented()
            }
        }
        
        // Handle initial intent if app was launched from widget
        if (intent?.action == "SWITCH_TO_WORKOUT_MODE" || intent?.action == "OPEN_DASHBOARD" || intent?.action == "OPEN_WORKOUT_PAGE") {
            pendingAction = intent?.action
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val action = intent.action
        if (action == "SWITCH_TO_WORKOUT_MODE" || action == "OPEN_DASHBOARD" || action == "OPEN_WORKOUT_PAGE") {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL).invokeMethod(action, null)
            }
        }
    }
}
