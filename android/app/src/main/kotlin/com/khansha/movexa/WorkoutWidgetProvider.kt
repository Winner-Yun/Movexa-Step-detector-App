package com.khansha.movexa

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WorkoutWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.workout_widget)

            val isWorkoutMode = widgetData.getBoolean("is_workout_mode", false)
            val isLoggedIn = widgetData.getBoolean("is_logged_in", false)

            if (!isLoggedIn) {
                views.setViewVisibility(R.id.layout_logged_out, View.VISIBLE)
                views.setViewVisibility(R.id.layout_daily, View.GONE)
                views.setViewVisibility(R.id.layout_workout, View.GONE)
                
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            } else {
                views.setViewVisibility(R.id.layout_logged_out, View.GONE)
                
                if (isWorkoutMode) {
                    views.setViewVisibility(R.id.layout_daily, View.GONE)
                    views.setViewVisibility(R.id.layout_workout, View.VISIBLE)
                    
                    views.setTextViewText(R.id.tv_workout_time, widgetData.getString("workout_time", "00:00"))
                    views.setTextViewText(R.id.tv_workout_steps, widgetData.getString("workout_steps", "0") + " steps")
                    views.setTextViewText(R.id.tv_workout_cal, widgetData.getString("workout_cal", "0") + " cal")
                    views.setTextViewText(R.id.tv_workout_km, widgetData.getString("workout_km", "0.0") + " km")
                    views.setTextViewText(R.id.tv_workout_speed, widgetData.getString("workout_speed", "0.0") + " km/h")

                    val intent = Intent(context, MainActivity::class.java).apply {
                        action = "OPEN_WORKOUT_PAGE"
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        1,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                } else {
                    views.setViewVisibility(R.id.layout_daily, View.VISIBLE)
                    views.setViewVisibility(R.id.layout_workout, View.GONE)
                    
                    views.setTextViewText(R.id.tv_daily_steps, widgetData.getString("daily_steps", "0") + " steps")
                    val dailyCal = widgetData.getString("daily_cal", "0")
                    val dailyKm = widgetData.getString("daily_km", "0.0")
                    views.setTextViewText(R.id.tv_daily_stats, "$dailyCal cal • $dailyKm km")

                    val intentDashboard = Intent(context, MainActivity::class.java).apply {
                        action = "OPEN_DASHBOARD"
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntentDashboard = PendingIntent.getActivity(
                        context,
                        2,
                        intentDashboard,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.widget_root, pendingIntentDashboard)
                    
                    val intentSwitch = Intent(context, MainActivity::class.java).apply {
                        action = "SWITCH_TO_WORKOUT_MODE"
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntentSwitch = PendingIntent.getActivity(
                        context,
                        3,
                        intentSwitch,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.btn_workout_mode, pendingIntentSwitch)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
