package com.example.ex_sdk_matrix

import android.animation.PropertyValuesHolder
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources.Theme
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Binder
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.view.*
import android.view.WindowManager.LayoutParams
import android.view.animation.BounceInterpolator
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngineCache
import java.util.*


class WindowService : Service() {

    lateinit var mWindowManager: WindowManager
    lateinit var mView: View
    var imageClose: ImageView? = null

    var isStopService: Boolean = false;
    var isExpanded: Boolean = true;
    var isStop: Boolean = false;

    override fun onBind(intent: Intent?): IBinder? {
        return null
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

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
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

        val params: LayoutParams = LayoutParams(
            500,
            500,
            LayoutParams.TYPE_APPLICATION_OVERLAY,
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
                        }else if(!isExpanded
                            && event.rawX -  xTouch < 20
                            && event.rawX -  xTouch > -20
                            && event.rawY -  yTouch < 20
                            && event.rawY -  yTouch > -20
                        ){
                            isExpanded = true
                            changeSizeFlag()
                        }else if(!isStop){
                            val layoutParams = (mView as FlutterView).layoutParams as LayoutParams

                            val endPos = if(params.x < WindowConfig.widthScreen / 2) 0
                            else WindowConfig.widthScreen - (WindowConfig.getCollapseSize(applicationContext)["width"] ?: 0)

                            moveAnimationPosition(
                                fromPosition =  Offset(params.x, params.y),
                                toPosition =  Offset(endPos, params.y),
                                view =  mView,
                                layoutParams =  layoutParams,
                                500,
                                BounceInterpolator()
                            )
                        }

                        if(imageClose != null){
                            mWindowManager.removeView(imageClose)
                            imageClose = null
                        }

                        if(isStop){
                            Log.e("WindowService", "Stop self service")
                            stopSelf()
                        }
                    }
                    MotionEvent.ACTION_MOVE ->{
                        if(!isExpanded){
                            params.x = xView + (event.rawX.toInt()) - xTouch.toInt()
                            params.y = yView + (event.rawY.toInt()) - yTouch.toInt()


                            if(imageClose == null){
                                imageClose = getIconClose(150, 150)
                                mWindowManager.addView(imageClose, imageClose!!.layoutParams as LayoutParams)
                            }

                            if(event.rawX >= (WindowConfig.widthScreen / 2 - 200)
                                && event.rawX <= (WindowConfig.widthScreen / 2 + 200)
                                && event.rawY >= (WindowConfig.heightScreen - 300)
                            ){
                                if(!isStop){

                                   moveAnimationPosition(
                                        fromPosition =  Offset(params.x, params.y),
                                        toPosition =  calPositionClose(mView.width, mView.height),
                                        view =  mView,
                                        layoutParams =  params,
                                        100,
                                        BounceInterpolator()
                                    )
                                }
                                isStop = true
                                 changeSizeIconClose(imageClose!!, 200, 200, Color.RED)
                                if(!isStopService) mWindowManager.updateViewLayout(imageClose, imageClose!!.layoutParams as LayoutParams)
                            }else{
                                isStop = false
                                if(!isStopService) mWindowManager.updateViewLayout(mView, params)

                                changeSizeIconClose(imageClose!!, 150, 150, null)
                                if(!isStopService) mWindowManager.updateViewLayout(imageClose, imageClose!!.layoutParams as LayoutParams)
                            }

                            return true
                        }
                    }
                }
                return false
            }
        })
    }

    fun moveAnimationPosition(
        fromPosition: Offset,
        toPosition: Offset,
        view: View,
        layoutParams: LayoutParams,
        duration: Int?,
        animation: android.animation.TimeInterpolator?,
    ){
        val propertyX = PropertyValuesHolder.ofInt("PROPERTY_X", fromPosition.x, toPosition.x)
        val propertyY = PropertyValuesHolder.ofInt("PROPERTY_Y", fromPosition.y, toPosition.y)

        val animator  = ValueAnimator().apply {
            setValues(propertyX, propertyY)
            this.duration = (duration ?: 500).toLong()
            this.interpolator =  animation
            this.addUpdateListener { animation ->
                Log.e("WindowService", "PROPERTY_X: ${animation.getAnimatedValue("PROPERTY_X") as Int}")
                Log.e("WindowService", "PROPERTY_Y: ${animation.getAnimatedValue("PROPERTY_Y") as Int}")
                layoutParams.x = animation.getAnimatedValue("PROPERTY_X") as Int
                layoutParams.y = animation.getAnimatedValue("PROPERTY_Y") as Int
                if(!isStopService) mWindowManager.updateViewLayout(view, layoutParams)
            }
        }
        animator.start()
    }

    fun calPositionClose(width: Int, height: Int): Offset{
        return Offset(
            (WindowConfig.widthScreen / 2) - (width / 2),
            (WindowConfig.heightScreen - 100) - (height / 2)
        )
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

        if(!isStopService) mWindowManager.updateViewLayout(mView, params)
    }

    fun getIconClose(width: Int, height: Int): ImageView{
        val position = calPositionClose(width, height)
        val myImageClose = ImageView(applicationContext).apply {
            setImageResource(R.drawable.icon_close)
            setColorFilter(Color.WHITE)
            layoutParams = LayoutParams(
                width,
                height,
                LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowConfig.getFlag(isExpanded),
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = position.x
                y = position.y
            }
        }
        return myImageClose;
    }

    fun changeSizeIconClose(view: ImageView, width: Int, height: Int, color: Int?){
        val position = calPositionClose(width, height)
        view.setColorFilter(color ?: Color.WHITE)
        view.layoutParams = LayoutParams(
            width,
            height,
            LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowConfig.getFlag(isExpanded),
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = position.x
            y = position.y
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isStopService = true;
        if(imageClose != null) mWindowManager.removeView(imageClose)
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