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
import android.widget.RemoteViews
import android.util.Log
import android.widget.ImageView
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.PorterDuffXfermode
import android.graphics.PorterDuff

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
            val channelName = "앱 알림 및 상단바 설정"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, channelName, importance).apply {
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "showCustomNotification" -> {
                    val arguments = call.arguments as Map<String, Any>

                    val dDayCount = arguments["dDayCount"] as Int
                    val topBarStyle = arguments["topBarStyle"] as Int
                    val myProfileImageBytes = arguments["myProfileImage"] as ByteArray
                    val loverProfileImageBytes = arguments["loverProfileImage"] as ByteArray
                    Log.d("데이터 확인1", "myProfileImageBytes: $myProfileImageBytes")
                    Log.d("데이터 확인1", "loverProfileImageBytes: $loverProfileImageBytes")

                    // 이미지를 Bitmap으로 변환
                    val myProfileBitmap = BitmapFactory.decodeByteArray(myProfileImageBytes, 0, myProfileImageBytes.size)
                    val loverProfileBitmap = BitmapFactory.decodeByteArray(loverProfileImageBytes, 0, loverProfileImageBytes.size)

                    result.success("Image received and set.")

                    if (dDayCount != null && topBarStyle != null) {
                        showCustomNotification(dDayCount, topBarStyle, getCircularBitmap(myProfileBitmap), getCircularBitmap(loverProfileBitmap))
                        result.success("Notification Shown")
                    } else {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments provided", null)
                    }
                }

                "cancelNotification" -> {
                    cancelNotification()
                    result.success("Notification Cancelled")
                }

                else -> {
                    result.notImplemented()
                }
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

    private fun showCustomNotification(dDayCount: Int, topBarStyle: Int, myProfileBitmap: Bitmap, loverProfileBitmap: Bitmap) {
        val channelId = CHANNEL_ID
//        val channelName = "Custom Notification"
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "디데이 상단바",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java)
//        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        val pendingIntent =
            PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        // 상단바 스타일 1 커스텀뷰
        val top_bar_style1_customView =
            RemoteViews(packageName, R.layout.top_bar_style_1_2_layout)
        top_bar_style1_customView.setTextViewText(R.id.top_bar_style_1_2_text, "${dDayCount}일")
        top_bar_style1_customView.setImageViewResource(
            R.id.top_bar_style_1_2_image,
            R.drawable.like_4x
        )

        // 상단바 스타일 2 커스텀뷰
        val top_bar_style2_customView =
            RemoteViews(packageName, R.layout.top_bar_style_1_2_layout)
        top_bar_style2_customView.setTextViewText(R.id.top_bar_style_1_2_text, "+ ${dDayCount}")
        top_bar_style2_customView.setImageViewResource(
            R.id.top_bar_style_1_2_image,
            R.drawable.like_4x
        )

        // 상단바 스타일 3 커스텀뷰
        val top_bar_style3_customView = RemoteViews(packageName, R.layout.top_bar_style_3_layout)

        top_bar_style3_customView.setImageViewBitmap(R.id.top_bar_style_3_image1, myProfileBitmap)
        top_bar_style3_customView.setImageViewResource(
            R.id.top_bar_style_3_image2,
            R.drawable.like_4x
        )
        top_bar_style3_customView.setTextViewText(R.id.top_bar_style_3_text, "${dDayCount}일")
        top_bar_style3_customView.setImageViewBitmap(R.id.top_bar_style_3_image3, loverProfileBitmap)


        // 상단바 스타일 4 커스텀뷰
        val top_bar_style4_customView = RemoteViews(packageName, R.layout.top_bar_style_4_layout)

        top_bar_style4_customView.setImageViewResource(
            R.id.top_bar_style_4_image1,
            R.drawable.like_4x
        )
        top_bar_style4_customView.setTextViewText(R.id.top_bar_style_4_text, "${dDayCount}일")
        top_bar_style4_customView.setImageViewBitmap(R.id.top_bar_style_4_image2, myProfileBitmap)
        top_bar_style4_customView.setImageViewBitmap(R.id.top_bar_style_4_image3, loverProfileBitmap)


        // 각 경우에 맞는 커스텀 뷰 선택
        val customView = when (topBarStyle) {
            1 -> top_bar_style1_customView
            2 -> top_bar_style2_customView
            3 -> top_bar_style3_customView
            4 -> top_bar_style4_customView
            else -> top_bar_style1_customView
        }

        val notification = NotificationCompat.Builder(this, channelId)
//            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setStyle(null)
            .setCustomContentView(customView)
//            .setContentTitle("${dDayCount}일??")
//            .setContentText("이미지가 포함된 알림 예제입니다.")
            .setSmallIcon(R.drawable.like_4x)  // 작은 아이콘
//            .setLargeIcon(BitmapFactory.decodeResource(resources, R.drawable.like))  // 큰 아이콘
//            .setStyle(NotificationCompat.BigPictureStyle()
//                .bigPicture(BitmapFactory.decodeResource(resources, R.drawable.like))  // 큰 이미지
//                .bigLargeIcon(null as Bitmap?)
//                .bigLargeIcon(BitmapFactory.decodeResource(resources, R.drawable.like))
//             )
            .setContentIntent(pendingIntent)
            .setAutoCancel(false)  // 클릭해도 알림이 자동으로 사라지지 않음
            .setOngoing(true)      // 고정 알림 설정
            .setShowWhen(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)  // 높은 우선순위 설정
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }


    // 고정된 알림을 종료하는 메서드
    private fun cancelNotification() {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }

    fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        val size = Math.min(bitmap.width, bitmap.height)
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(output)
        val paint = Paint()
        paint.isAntiAlias = true

        val rect = Rect(0, 0, size, size)
        val rectF = RectF(rect)

        canvas.drawOval(rectF, paint)

        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(bitmap, rect, rect, paint)

        return output
    }
}