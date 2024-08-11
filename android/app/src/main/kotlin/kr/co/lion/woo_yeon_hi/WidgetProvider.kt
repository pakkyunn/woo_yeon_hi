package kr.co.lion.woo_yeon_hi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context
import android.content.pm.PackageManager;
import android.os.SystemClock;

import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kr.co.lion.woo_yeon_hi.R
import kr.co.lion.woo_yeon_hi.MainActivity
import java.text.SimpleDateFormat
import android.util.Log
import java.text.ParseException
import java.util.Calendar
import java.util.Date
import java.util.Locale


class AppWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                Log.d("AppWidgetProvider", "onUpdate called")
                Log.d("AppWidgetProvider", "Updating widget ID: $widgetId")

                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_layout, pendingIntent)

                val loveDdayString = widgetData.getString("loveDday", null)
                if (loveDdayString != null) {
                    Log.d("AppWidgetProvider", "읽어온 날짜: $loveDdayString")
                    // 날짜를 읽어와서 계산
                } else {
                    Log.d("AppWidgetProvider", "날짜를 읽어오지 못했습니다. 기본값을 설정합니다.")
                    // 기본값 또는 다른 로직 처리
                }

                val dDayCounter: Int

                if (loveDdayString != null) {
                    val startDate = _stringToDate(loveDdayString)

                    if (startDate != null) {
                        val currentDate = Calendar.getInstance().apply {
                            set(Calendar.HOUR_OF_DAY, 0)
                            set(Calendar.MINUTE, 0)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                        }

                        val startCalendar = Calendar.getInstance().apply {
                            time = startDate
                            set(Calendar.HOUR_OF_DAY, 0)
                            set(Calendar.MINUTE, 0)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                        }

                        // 두 날짜의 차이를 '일' 단위로 계산
                        val diffInMillis = currentDate.timeInMillis - startCalendar.timeInMillis
                        dDayCounter = (diffInMillis / (1000 * 60 * 60 * 24)).toInt() + 1
                    } else {
                        // startDate가 null인 경우 처리
                        dDayCounter = 0
                    }
                } else {
                    // loveDdayString이 null인 경우 처리
                    dDayCounter = 0
                }

                val dDayCounterText = "우리가 만난지\n${dDayCounter}일 째"
                setTextViewText(R.id.dDay_counter, dDayCounterText)

                // Pending intent to update counter on button click
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("myAppWidget://updatecounter")
                )
                setOnClickPendingIntent(R.id.dDay_counter, backgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun _stringToDate(dateString: String): Date? {
        val dateFormat = SimpleDateFormat("yyyy. MM. d.", Locale.getDefault())
        return try {
            dateFormat.parse(dateString)
        } catch (e: ParseException) {
            e.printStackTrace()
            null
        }
    }
}
