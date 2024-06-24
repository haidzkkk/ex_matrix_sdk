package com.example.ex_sdk_matrix

import android.app.Activity
import android.content.Context
import android.util.DisplayMetrics

class WindowConfig {
    companion object{
        fun getCollapseSize(): Map<String, Double>{
            return mapOf(
                "width" to 60.0,
                "height" to 60.0,
            )
        }

        fun getExpandSize(context: Context): Map<String, Double>{
            return mapOf(
//                "width" to (getWidth(context) * 0.9),
//                "height" to (getHeight(context) * 0.9),
                "width" to 200.0,
                "height" to 200.0,
            )
        }
    }
}

fun getWidth(context: Context): Double{
    val displayMetrics = DisplayMetrics()
    (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
    return  displayMetrics.widthPixels.toDouble()
}

fun getHeight(context: Context): Double{
    val displayMetrics = DisplayMetrics()
    (context as Activity).windowManager.defaultDisplay.getMetrics(displayMetrics)
    return  displayMetrics.heightPixels.toDouble()
}