package com.example.ex_sdk_matrix

import android.app.Activity
import android.content.Context
import android.graphics.Insets
import android.os.Build
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.WindowInsets
import android.view.WindowManager
import android.view.WindowMetrics


class WindowConfig {
    companion object{
        var widthScreen: Int = 0
        var heightScreen: Int = 0

        fun getCollapseSize(context: Context): Map<String, Int>{
            return mapOf(
                "width" to dpToPx(context, 71.0) ,
                "height" to dpToPx(context, 71.0) ,
            )
        }

        fun getExpandSize(): Map<String, Int>{
            return mapOf(
                "width" to widthScreen,
                "height" to heightScreen,
            )
        }

        fun getSizeScreen(context: Context){
            widthScreen = getWidth(context);
            heightScreen = getHeight(context);
        }

        fun getFlag(isExpanded: Boolean): Int{
            return if(isExpanded){
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
            }else{
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
            }
        }

    }
}

fun getWidth(context: Context): Int{
    val displayMetrics = DisplayMetrics()
    (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
    return displayMetrics.widthPixels
}

fun getHeight(context: Context): Int{
    val displayMetrics = DisplayMetrics()
    (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
    return displayMetrics.heightPixels - 60  /// actionbar
}

private fun dpToPx(context: Context, dp: Double): Int {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        (dp.toString() + "").toFloat(),
        context.resources.displayMetrics
    ).toInt()
}