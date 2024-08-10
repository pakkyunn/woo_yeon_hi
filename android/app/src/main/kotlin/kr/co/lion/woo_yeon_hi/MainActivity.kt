package kr.co.lion.woo_yeon_hi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 앱 시작 시점에 위젯을 강제로 업데이트
        updateAppWidget()
    }

    private fun updateAppWidget() {
        val context = this
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, AppWidgetProvider::class.java)
        val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)

        // 위젯을 강제로 업데이트
        appWidgetManager.notifyAppWidgetViewDataChanged(allWidgetIds, R.id.widget_layout)
    }
}