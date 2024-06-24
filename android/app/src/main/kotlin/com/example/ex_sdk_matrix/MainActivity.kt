package com.example.method_chanel

import android.app.ActivityManager
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.provider.Settings
import com.example.ex_sdk_matrix.WindowConfig
import com.example.ex_sdk_matrix.WindowService
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){

    var myService: WindowService? = null
    var isConnect = false

    private var connection = object :  ServiceConnection{
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as WindowService.MyBinder
            myService = binder.getService()
            isConnect = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            myService = null
            isConnect = false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        setViewFromFlutter()
        setMethodCallHandle(flutterEngine)
    }

    private fun setViewFromFlutter() {
        if(FlutterEngineCache.getInstance().get("engine") == null){
            val enn = FlutterEngineGroup(context)
            val dEntry = DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "overlayMain"
            )
            val engine = enn.createAndRunEngine(context, dEntry)
            FlutterEngineCache.getInstance().put("engine", engine)
        }
    }

    private fun setMethodCallHandle(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.method_chanel/showOverlay")
            .setMethodCallHandler { call, result ->
                if(call.method.equals("runService")){
                    if (checkRunningService(WindowService::class.java)) {
                        result.success("Service is stated")
                    }else{
                        if(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                                !Settings.canDrawOverlays(this)
                            else false
                        ){
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName"))
                            startActivityForResult(intent, 12312312);
                        }

                        val title: String? = call.argument("title")
                        val body: String? = call.argument("body")

                        val bundle = Bundle().apply {
                            putString("title", title)
                            putString("body", body)
                        }
                        val intent = Intent(this, WindowService::class.java)
                        intent.putExtra("main", bundle)

                        bindService(intent, connection, Context.BIND_AUTO_CREATE)
                        startService(intent)

                        result.success("Start service success")
                    }
                }else if(call.method.equals("stopService")){
                    if(!isConnect){
                        result.success("Service stopped")
                    }

                    unbindService(connection)
                    isConnect = false
                    stopService(Intent(this, WindowService::class.java))
                    result.success("Stop service success")

                }else if(call.method.equals("changeSize")){
                    if(!isConnect){
                        result.success("Service stopped")
                    }else{
                        result.success("Change size success")
                    }
                }else if(call.method.equals("changePosition")){
                    if(!isConnect){
                        result.success("Service stopped")
                    }else{
                        result.success("Change position success")
                    }
                }else{
                    result.notImplemented()
                }
            }
    }

    private fun checkRunningService(serviceClass: Class<out Service>): Boolean{
        if(isConnect){
            return true
        }
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in activityManager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }
}

