package com.example.method_chanel

import android.app.ActivityManager
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import android.os.Bundle
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import com.example.ex_sdk_matrix.AppConstants
import com.example.ex_sdk_matrix.WindowConfig
import com.example.ex_sdk_matrix.WindowService
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MainActivity: FlutterActivity(), MethodCallHandler{


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        WindowConfig.getSizeScreen(context)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AppConstants.METHOD_CHANNEL
        ).setMethodCallHandler(this)
    }

    private fun setViewFromFlutterEngineCache() {
        if(FlutterEngineCache.getInstance().get(AppConstants.CACHED_TAG) == null){
            val enn = FlutterEngineGroup(context)
            val dEntry = DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                AppConstants.VIEW_FROM_MAIN_FLUTTER
            )
            val engine = enn.createAndRunEngine(context, dEntry)
            FlutterEngineCache.getInstance().put(AppConstants.CACHED_TAG, engine)
        }
    }

    private fun removeViewFromFlutterEngineCache() {
        if(FlutterEngineCache.getInstance().get(AppConstants.CACHED_TAG) != null){
            FlutterEngineCache.getInstance().remove(AppConstants.CACHED_TAG)
        }
    }

    private fun checkRunningService(serviceClass: Class<out Service>): Boolean{
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in activityManager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method){
            "runService" -> {
                setViewFromFlutterEngineCache()
                runService(call, result)
                return
            }
            "stopService" -> {
                removeViewFromFlutterEngineCache()
                stopService(call, result)
                return
            }
            "hasPermission" -> {
                result.success(Settings.canDrawOverlays(this))
                return
            }
            "requestOverlayPermission" -> {
                requestPermissionOverlay()
                result.success("requestOverlayPermission success")
                return
            }
            else ->{
                result.notImplemented()
            }
        }
    }

    private fun runService(call: MethodCall, result: MethodChannel.Result){
        if (checkRunningService(WindowService::class.java)) {
            result.success("Service is stated")
        }else{
            if(Settings.canDrawOverlays(this)){
                val title: String? = call.argument("title")
                val body: String? = call.argument("body")

                val bundle = Bundle().apply {
                    putString("title", title)
                    putString("body", body)
                }
                val intent = Intent(this, WindowService::class.java)
                intent.putExtra("main", bundle)

                startService(intent)

                result.success("Start service success")
            }
        }
    }

    private fun stopService(call: MethodCall, result: MethodChannel.Result){
        if(checkRunningService(WindowService::class.java)){
            stopService(Intent(this, WindowService::class.java))
        }

    }

    private fun requestPermissionOverlay(){
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:$packageName"))
        startActivityForResult(intent, 12312312);
    }
}

