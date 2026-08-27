package com.javis.tokenmonitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TokenMonitorWidget2x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_token_monitor_2x2).apply {
                val cost = widgetData.getString("today_cost", "$0.00")
                val tokens = widgetData.getString("today_tokens", "0 Tokens")
                val claude = widgetData.getString("claude_quota", "--")

                setTextViewText(R.id.tv_today_cost_2x2, cost)
                setTextViewText(R.id.tv_today_tokens_2x2, tokens)
                setTextViewText(R.id.tv_claude_quota_2x2, claude)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
