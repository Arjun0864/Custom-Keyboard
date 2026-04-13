package com.flutterboard.keyboard

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SETTINGS_CHANNEL = "com.flutterboard/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isKeyboardEnabled" -> {
                        result.success(isKeyboardEnabled())
                    }
                    "isKeyboardSelected" -> {
                        result.success(isKeyboardSelected())
                    }
                    "openKeyboardSettings" -> {
                        openKeyboardSettings()
                        result.success(null)
                    }
                    "openInputMethodPicker" -> {
                        openInputMethodPicker()
                        result.success(null)
                    }
                    "getAndroidVersion" -> {
                        result.success(android.os.Build.VERSION.SDK_INT)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isKeyboardEnabled(): Boolean {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        val enabledMethods = imm.enabledInputMethodList
        return enabledMethods.any { it.packageName == packageName }
    }

    private fun isKeyboardSelected(): Boolean {
        val currentIME = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.DEFAULT_INPUT_METHOD
        )
        return currentIME?.startsWith(packageName) == true
    }

    private fun openKeyboardSettings() {
        startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS))
    }

    private fun openInputMethodPicker() {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        imm.showInputMethodPicker()
    }
}
