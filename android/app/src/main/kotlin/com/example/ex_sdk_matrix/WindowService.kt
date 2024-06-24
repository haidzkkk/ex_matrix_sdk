package com.example.ex_sdk_matrix

import android.annotation.SuppressLint
import android.app.*
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Binder
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.util.TypedValue
import android.view.*
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngineCache
import java.util.*


class WindowService : Service() {

    val CHANNEL_ID = "CHANNEL_ID"

    lateinit var mWindowManager: WindowManager
    lateinit var mView: View

    var isExpanded: Boolean = false;


    var mBinder = MyBinder()
    inner class MyBinder : Binder(){
        fun getService(): WindowService{
            return this@WindowService
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return mBinder
    }

    override fun onCreate() {
        super.onCreate()
        createChannelNotify()
        print("Service dang chay ")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val bundleMain: Bundle? = intent?.getBundleExtra("main")

        if(bundleMain != null){
            val title: String? = bundleMain.getString("title")
            val body: String? = bundleMain.getString("body")
            handleMainFeature(title, body)
        }

        return START_STICKY
    }

    private fun handleMainFeature(title: String?, body: String?) {
        Log.e("service123213", "service $title: $body")

        isExpanded = false;
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .build()

        startForeground(1, notification)

        val engine = FlutterEngineCache.getInstance()["engine"]
        engine!!.lifecycleChannel.appIsResumed()
        mView = FlutterView(applicationContext, FlutterTextureView(applicationContext))
        (mView as FlutterView).attachToFlutterEngine(FlutterEngineCache.getInstance()["engine"]!!)
        mView.fitsSystemWindows = true
        mView.isFocusable = true
        mView.isFocusableInTouchMode = true
        mView.setBackgroundColor(Color.TRANSPARENT)
        (mView as FlutterView).apply {
        }

        val LAYOUT_FLAG: Int =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE

        val params: WindowManager.LayoutParams = WindowManager.LayoutParams(
            500,
            500,
            LAYOUT_FLAG,
//            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 100
        }

        mWindowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        mWindowManager.addView(mView, params)

        mView.rootView.setOnTouchListener(object: View.OnTouchListener{
            private var initialX = 0
            private var initialY = 0
            private var lastX = 0f
            private var lastY = 0f

            @SuppressLint("ClickableViewAccessibility")
            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                when(event?.action){
                    MotionEvent.ACTION_DOWN ->{
                        initialX = params.x
                        initialY = params.y
                        lastX = event.rawX
                        lastY = event.rawY
                        return false
                    }
                    MotionEvent.ACTION_UP ->{
                        isExpanded = !isExpanded
                        val size: Map<String, Double> = if (isExpanded) WindowConfig.getExpandSize(applicationContext) else WindowConfig.getCollapseSize()

                        changeSize(size["width"] ?: 0.0, size["height"] ?: 0.0)
                    }
                    MotionEvent.ACTION_MOVE ->{
                        params.x = initialX + (event.rawX.toInt()) - lastX.toInt()
                        params.y = initialY + (event.rawY.toInt()) - lastY.toInt()
                        mWindowManager.updateViewLayout(mView, params)

                        return true
                    }
                }
                return false
            }
        })
    }

    fun changeSize(x: Double, y: Double) {
        Log.e("size screen service", "widget: $x - height: $y ")
        val params = (mView as FlutterView).layoutParams
        params.width = dpToPx(x)
        params.height = dpToPx(y)
        mWindowManager.updateViewLayout(mView, params)
    }

    fun moveOverlay(x: Double, y: Double) {
        val params = (mView as FlutterView).layoutParams as WindowManager.LayoutParams
        params.x = dpToPx(x)
        params.y = dpToPx(y)
        mWindowManager.updateViewLayout(mView, params)
    }

    override fun onDestroy() {
        super.onDestroy()
        mWindowManager.removeView(mView)
        print("Service Đã tắt")
    }


    private fun createChannelNotify() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            val notificationManager = getSystemService(NotificationManager::class.java) as NotificationManager

            val channel1 = NotificationChannel(CHANNEL_ID, "CHANNEL_NAME", NotificationManager.IMPORTANCE_DEFAULT)
            channel1.setSound(null, null)
            notificationManager.createNotificationChannel(channel1)
        }
    }

    private fun dpToPx(dp: Double): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            (dp.toString() + "").toFloat(),
            applicationContext.resources.displayMetrics
        ).toInt()
    }
}