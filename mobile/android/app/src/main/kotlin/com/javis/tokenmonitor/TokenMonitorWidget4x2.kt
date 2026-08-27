package com.javis.tokenmonitor

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TokenMonitorWidget4x2 : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_token_monitor_4x2).apply {
                val cost = widgetData.getString("today_cost", "$0.00")
                val tokens = widgetData.getString("today_tokens", "0 Tokens")
                val claude = widgetData.getString("claude_quota", "--")
                val codex = widgetData.getString("codex_quota", "--")
                val time = widgetData.getString("last_updated", "--:--")

                setTextViewText(R.id.tv_today_cost, cost)
                setTextViewText(R.id.tv_today_tokens, tokens)
                setTextViewText(R.id.tv_claude_quota, claude)
                setTextViewText(R.id.tv_codex_quota, codex)
                setTextViewText(R.id.tv_updated_time, "更新于 " + time)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
