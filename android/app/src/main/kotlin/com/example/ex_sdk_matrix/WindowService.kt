package com.example.ex_sdk_matrix

import android.annotation.SuppressLint
import android.app.*
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Binder
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.view.*
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngineCache
import java.util.*


class WindowService : Service() {

    lateinit var mWindowManager: WindowManager
    lateinit var mView: View

    var isExpanded: Boolean = true;


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
        val notification: Notification = NotificationCompat.Builder(this, AppConstants.CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .build()

        startForeground(1, notification)

        val engine = FlutterEngineCache.getInstance()[AppConstants.CACHED_TAG]
        engine!!.lifecycleChannel.appIsResumed()
        mView = FlutterView(applicationContext, FlutterTextureView(applicationContext))
        (mView as FlutterView).attachToFlutterEngine(FlutterEngineCache.getInstance()[AppConstants.CACHED_TAG]!!)
        (mView as FlutterView).childCount
        mView.fitsSystemWindows = true
        mView.isFocusable = true
        mView.isFocusableInTouchMode = true
        mView.setBackgroundColor(Color.TRANSPARENT)

        val params: WindowManager.LayoutParams = WindowManager.LayoutParams(
            500,
            500,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowConfig.getFlag(isExpanded),
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 100
        }
        mWindowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        mWindowManager.addView(mView, params)
        changeSizeFlag()

        mView.rootView.setOnTouchListener(object: View.OnTouchListener{
            private var xView = 0
            private var yView = 0
            private var xTouch = 0f
            private var yTouch = 0f

            @SuppressLint("ClickableViewAccessibility")
            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                when(event?.action){
                    MotionEvent.ACTION_DOWN ->{
                        xView = params.x
                        yView = params.y
                        xTouch = event.rawX
                        yTouch = event.rawY
                        return false
                    }
                    MotionEvent.ACTION_UP ->{
                        if(isExpanded
                        && (xTouch < (WindowConfig.widthScreen / 2 - 60) || xTouch > WindowConfig.widthScreen / 2 + 60)
                        && yTouch < 250
                        ){
                            isExpanded = false
                            changeSizeFlag()
                        }else if(!isExpanded &&
                            event.rawX -  xTouch < 20
                            && event.rawX -  xTouch > -20
                        ){
                            isExpanded = true
                            changeSizeFlag()
                        }

                    }
                    MotionEvent.ACTION_MOVE ->{
                        if(!isExpanded){
                            params.x = xView + (event.rawX.toInt()) - xTouch.toInt()
                            params.y = yView + (event.rawY.toInt()) - yTouch.toInt()
                            mWindowManager.updateViewLayout(mView, params)

                            return true
                        }
                    }
                }
                return false
            }
        })
    }

    fun changeSizeFlag() {
        val params = (mView as FlutterView).layoutParams as WindowManager.LayoutParams
        val size: Map<String, Int> =
            if (isExpanded) WindowConfig.getExpandSize()
            else WindowConfig.getCollapseSize(applicationContext)
        val flag = WindowConfig.getFlag(isExpanded)

        params.width = size["width"] ?: 0;
        params.height = size["height"] ?: 0;

        params.flags = flag

        mWindowManager.updateViewLayout(mView, params)
    }

    override fun onDestroy() {
        super.onDestroy()
        mWindowManager.removeView(mView)
        print("Service Đã tắt")
    }


    private fun createChannelNotify() {
        val notificationManager = getSystemService(NotificationManager::class.java) as NotificationManager

        val channel1 = NotificationChannel(AppConstants.CHANNEL_ID, "CHANNEL_NAME", NotificationManager.IMPORTANCE_DEFAULT)
        channel1.setSound(null, null)
        notificationManager.createNotificationChannel(channel1)
    }
}