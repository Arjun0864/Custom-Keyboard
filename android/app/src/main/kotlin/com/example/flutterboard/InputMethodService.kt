package com.example.flutterboard

import android.inputmethodservice.InputMethodService
import android.inputmethodservice.Keyboard
import android.inputmethodservice.KeyboardView
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import android.os.Build

/**
 * InputMethodService - Main IME Service that bridges Flutter UI with Android text input
 * 
 * This service:
 * - Extends Android's InputMethodService
 * - Embeds Flutter engine to render custom keyboard UI
 * - Routes text input from Flutter back to the connected app
 * - Manages keyboard lifecycle and state
 */
class InputMethodService : InputMethodService() {
    
    private var flutterView: FlutterView? = null
    private var flutterEngine: FlutterEngine? = null
    private var inputConnection: InputConnection? = null
    private var editorInfo: EditorInfo? = null
    
    companion object {
        private const val TAG = "FlutterBoardIME"
        private const val CHANNEL_NAME = "com.example.flutterboard/ime"
    }
    
    /**
     * Called when the IME is first created
     */
    override fun onCreate() {
        super.onCreate()
        initializeFlutterEngine()
    }
    
    /**
     * Initialize Flutter engine and view
     */
    private fun initializeFlutterEngine() {
        try {
            // Create Flutter Engine
            flutterEngine = FlutterEngine(this)
            
            // Attach to the dart executor
            flutterEngine?.dartExecutor?.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            
            // Create Flutter View
            flutterView = FlutterView(this).apply {
                attachToFlutterEngine(flutterEngine!!)
            }
            
            // Setup platform channel for communication
            setupPlatformChannel()
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error initializing Flutter engine", e)
        }
    }
    
    /**
     * Setup platform method channel for Flutter <-> Kotlin communication
     */
    private fun setupPlatformChannel() {
        if (flutterEngine == null) return
        
        val methodChannel = MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
    }
    
    /**
     * Called when the IME is started
     */
    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        this.editorInfo = attribute
        android.util.Log.d(TAG, "onStartInput called")
    }
    
    /**
     * Called when the fullscreen input view needs to be shown
     */
    override fun onStartInputView(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(attribute, restarting)
        
        // Create container for Flutter view
        val container = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        // Add Flutter view to container
        if (flutterView != null) {
            container.addView(flutterView)
        }
        
        // Set as input view
        setInputView(container)
    }
    
    /**
     * Called when text input is required
     */
    override fun onCreateInputView(): View? {
        val container = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        if (flutterView != null) {
            container.addView(flutterView)
        }
        
        return container
    }
    
    /**
     * Handle key press events from Flutter keyboard
     */
    fun onKeyPressed(keyCode: Int, keyChar: String) {
        val ic = currentInputConnection ?: return
        
        when (keyCode) {
            KeyEvent.KEYCODE_DEL -> {
                // Backspace
                ic.deleteSurroundingText(1, 0)
            }
            KeyEvent.KEYCODE_ENTER -> {
                // Enter/Return
                ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
            }
            KeyEvent.KEYCODE_SPACE -> {
                // Space
                ic.commitText(" ", 1)
            }
            else -> {
                // Regular character input
                if (keyChar.isNotEmpty()) {
                    ic.commitText(keyChar, 1)
                }
            }
        }
    }
    
    /**
     * Insert text at cursor position
     */
    fun insertText(text: String) {
        val ic = currentInputConnection ?: return
        ic.commitText(text, 1)
    }
    
    /**
     * Delete character(s) before cursor
     */
    fun deleteText(count: Int = 1) {
        val ic = currentInputConnection ?: return
        ic.deleteSurroundingText(count, 0)
    }
    
    /**
     * Get surrounding text context
     */
    fun getSurroundingText(beforeLength: Int, afterLength: Int): String? {
        val ic = currentInputConnection ?: return null
        return ic.getTextBeforeCursor(beforeLength, 0)?.toString()
    }
    
    /**
     * Called when the IME is being closed
     */
    override fun onFinishInput() {
        super.onFinishInput()
        this.inputConnection = null
        android.util.Log.d(TAG, "onFinishInput called")
    }
    
    /**
     * Called when the IME is destroyed
     */
    override fun onDestroy() {
        flutterEngine?.destroy()
        flutterView?.detachFromFlutterEngine()
        super.onDestroy()
    }
}
