package kr.co.lion.woo_yeon_hi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Bundle

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.graphics.Color

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "custom_notification_channel"
    companion object {
        const val CHANNEL_ID = "fixed_notification_channel"
        const val NOTIFICATION_ID = 1  // 알림을 식별하기 위한 ID
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 앱 시작 시점에 위젯을 강제로 업데이트
        updateAppWidget()

        // 알림 채널 생성 코드 추가
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = "Fixed Notification Channel"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, channelName, importance).apply {
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                description = "This channel is used for fixed notifications"
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showCustomNotification") {
                showCustomNotification()
                result.success("Notification Shown")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun updateAppWidget() {
        val context = this
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, AppWidgetProvider::class.java)
        val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)

        // 위젯을 강제로 업데이트
        appWidgetManager.notifyAppWidgetViewDataChanged(allWidgetIds, R.id.widget_layout)
    }

    private fun showCustomNotification() {
        val channelId = CHANNEL_ID
//        val channelName = "Custom Notification"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Custom Notification", NotificationManager.IMPORTANCE_HIGH).apply {
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                description = "This channel is used for fixed notifications"
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java)
//        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("309일")
//            .setContentText("이미지가 포함된 알림 예제입니다.")
            .setSmallIcon(R.drawable.heart_fill)  // 작은 아이콘
//            .setLargeIcon(BitmapFactory.decodeResource(resources, R.drawable.heart_fill))  // 큰 아이콘
            .setStyle(NotificationCompat.BigPictureStyle()
//                .bigPicture(BitmapFactory.decodeResource(resources, R.drawable.heart_fill))  // 큰 이미지
//                .bigLargeIcon(null as Bitmap?)
             )
            .setContentIntent(pendingIntent)
            .setAutoCancel(false)  // 클릭해도 알림이 자동으로 사라지지 않음
            .setOngoing(true)      // 고정 알림 설정
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)  // 높은 우선순위 설정
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }
}