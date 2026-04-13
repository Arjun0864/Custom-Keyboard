package com.example.flutterboard

import android.content.Context
import android.inputmethodservice.InputMethodService
import android.inputmethodservice.Keyboard
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

/**
 * FlutterBoard Input Method Service
 * Provides a custom keyboard experience using Flutter UI integrated with Android IME
 */
class FlutterBoardIME : InputMethodService() {

    companion object {
        const val ENGINE_ID = "flutterboard_ime_engine"
        const val METHOD_CHANNEL = "com.flutterboard/keyboard"
        const val EVENT_CHANNEL = "com.flutterboard/keyboard_events"
        const val INPUT_CHANNEL = "com.flutterboard/input"
    }

    private var flutterView: FlutterView? = null
    private var flutterEngine: FlutterEngine? = null
    private var methodChannel: MethodChannel? = null
    private var inputChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private var currentInputConnection: InputConnection? = null
    private var currentEditorInfo: EditorInfo? = null
    private var lastComposingText: String = ""

    override fun onCreate() {
        super.onCreate()
        initializeFlutterEngine()
    }

    /**
     * Initialize Flutter Engine for IME
     */
    private fun initializeFlutterEngine() {
        // Try to reuse cached engine for better performance
        var engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        
        if (engine == null) {
            engine = FlutterEngine(this)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        }
        
        flutterEngine = engine
        setupMethodChannels()
    }

    /**
     * Setup bidirectional communication channels between Kotlin and Dart
     */
    private fun setupMethodChannels() {
        val messenger = flutterEngine?.dartExecutor?.binaryMessenger ?: return

        // Main method channel for keyboard operations
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }
        }

        // Event channel for sending events to Flutter
        eventChannel = EventChannel(messenger, EVENT_CHANNEL).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }

        // Input channel for text and clipboard operations
        inputChannel = MethodChannel(messenger, INPUT_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                handleInputCall(call, result)
            }
        }
    }

    /**
     * Handle method calls from Flutter
     */
    private fun handleMethodCall(call: MethodChannel.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "commitText" -> {
                val text = call.argument<String>("text") ?: ""
                commitText(text)
                result.success(null)
            }

            "deleteBackward" -> {
                deleteBackward()
                result.success(null)
            }

            "deleteForward" -> {
                deleteForward()
                result.success(null)
            }

            "commitAction" -> {
                val action = call.argument<String>("action") ?: "done"
                performEditorAction(action)
                result.success(null)
            }

            "hideKeyboard" -> {
                requestHideSelf(0)
                result.success(null)
            }

            "vibrate" -> {
                val duration = call.argument<Int>("duration") ?: 30
                val strength = call.argument<Int>("strength") ?: 128
                performHapticFeedback(duration, strength)
                result.success(null)
            }

            "getSelectedText" -> {
                val text = getSelectedText()
                result.success(text)
            }

            "moveCursor" -> {
                val offset = call.argument<Int>("offset") ?: 0
                moveCursor(offset)
                result.success(null)
            }

            "selectAll" -> {
                selectAll()
                result.success(null)
            }

            "commitComposingText" -> {
                val text = call.argument<String>("text") ?: ""
                commitComposingText(text)
                result.success(null)
            }

            "setComposingText" -> {
                val text = call.argument<String>("text") ?: ""
                setComposingText(text)
                lastComposingText = text
                result.success(null)
            }

            "finishComposing" -> {
                finishComposing()
                result.success(null)
            }

            "getEditorInfo" -> {
                result.success(getEditorInfoMap())
            }

            "switchToPreviousInputMethod" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    switchToPreviousInputMethod()
                }
                result.success(null)
            }

            "showInputMethodPicker" -> {
                val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                imm?.showInputMethodPicker()
                result.success(null)
            }

            "isKeyboardMode" -> {
                // Called from main.dart to determine if running as IME
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Handle input-related method calls
     */
    private fun handleInputCall(call: MethodChannel.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getClipboardText" -> {
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? android.content.ClipboardManager
                val text = try {
                    clipboard?.primaryClip?.getItemAt(0)?.coerceToText(this)?.toString()
                } catch (e: Exception) {
                    null
                }
                result.success(text)
            }

            "setClipboardText" -> {
                val text = call.argument<String>("text") ?: ""
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? android.content.ClipboardManager
                val clip = android.content.ClipData.newPlainText("FlutterBoard", text)
                clipboard?.setPrimaryClip(clip)
                result.success(null)
            }

            "getSurroundingText" -> {
                val before = call.argument<Int>("before") ?: 50
                val after = call.argument<Int>("after") ?: 50
                val ic = currentInputConnection
                val textBefore = try {
                    ic?.getTextBeforeCursor(before, 0)?.toString() ?: ""
                } catch (e: Exception) {
                    ""
                }
                val textAfter = try {
                    ic?.getTextAfterCursor(after, 0)?.toString() ?: ""
                } catch (e: Exception) {
                    ""
                }
                result.success(mapOf("before" to textBefore, "after" to textAfter))
            }

            "getImeState" -> {
                result.success(mapOf(
                    "isEnabled" to true,
                    "currentInputConnection" to (currentInputConnection != null),
                    "editorInfo" to getEditorInfoMap()
                ))
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Create the input view (Flutter keyboard UI)
     */
    override fun onCreateInputView(): View {
        flutterView = FlutterView(this).apply {
            attachToFlutterEngine(flutterEngine!!)
        }

        // Notify Flutter that keyboard view is created
        methodChannel?.invokeMethod("onKeyboardCreated", null)

        return flutterView!!
    }

    /**
     * Called when the input view is starting to be shown
     */
    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        currentEditorInfo = info
        currentInputConnection = currentInputConnection

        // Notify Flutter
        val editorInfo = getEditorInfoMap()
        methodChannel?.invokeMethod("onStartInput", editorInfo)

        // Send event
        eventSink?.success(mapOf(
            "type" to "startInput",
            "editorInfo" to editorInfo
        ))
    }

    /**
     * Called when the input view is finishing
     */
    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        methodChannel?.invokeMethod("onFinishInput", null)
        eventSink?.success(mapOf("type" to "finishInput"))
    }

    /**
     * Called when the selection has changed
     */
    override fun onUpdateSelection(
        oldSelStart: Int, oldSelEnd: Int,
        newSelStart: Int, newSelEnd: Int,
        candidatesStart: Int, candidatesEnd: Int
    ) {
        super.onUpdateSelection(oldSelStart, oldSelEnd, newSelStart, newSelEnd, candidatesStart, candidatesEnd)
        eventSink?.success(mapOf(
            "type" to "selectionUpdate",
            "oldSelStart" to oldSelStart,
            "oldSelEnd" to oldSelEnd,
            "newSelStart" to newSelStart,
            "newSelEnd" to newSelEnd
        ))
    }

    // ====== Text Operations ======

    /**
     * Commit text to the current input connection
     */
    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    /**
     * Delete previous character
     */
    private fun deleteBackward() {
        val ic = currentInputConnection ?: return
        try {
            val selectedText = ic.getSelectedText(0)
            if (selectedText != null && selectedText.isNotEmpty()) {
                ic.commitText("", 1)
            } else {
                ic.deleteSurroundingText(1, 0)
            }
        } catch (e: Exception) {
            ic.deleteSurroundingText(1, 0)
        }
    }

    /**
     * Delete next character
     */
    private fun deleteForward() {
        currentInputConnection?.deleteSurroundingText(0, 1)
    }

    /**
     * Move cursor by offset
     */
    private fun moveCursor(offset: Int) {
        val ic = currentInputConnection ?: return
        try {
            val extracted = ic.getExtractedText(
                android.view.inputmethod.ExtractedTextRequest(),
                0
            )
            if (extracted != null) {
                val newPos = (extracted.selectionStart + offset).coerceIn(
                    0,
                    extracted.text.length
                )
                ic.setSelection(newPos, newPos)
            }
        } catch (e: Exception) {
            // Silently handle exceptions
        }
    }

    /**
     * Select all text in the input field
     */
    private fun selectAll() {
        currentInputConnection?.performContextMenuAction(android.R.id.selectAll)
    }

    /**
     * Get currently selected text
     */
    private fun getSelectedText(): String? {
        return try {
            currentInputConnection?.getSelectedText(0)?.toString()
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Set composing text (for text suggestions/predictions)
     */
    private fun setComposingText(text: String) {
        currentInputConnection?.setComposingText(text, 1)
    }

    /**
     * Commit composing text
     */
    private fun commitComposingText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    /**
     * Finish composing text
     */
    private fun finishComposing() {
        currentInputConnection?.finishComposingText()
    }

    /**
     * Perform editor action (done, go, search, etc.)
     */
    private fun performEditorAction(action: String) {
        val actionCode = when (action) {
            "done" -> EditorInfo.IME_ACTION_DONE
            "go" -> EditorInfo.IME_ACTION_GO
            "search" -> EditorInfo.IME_ACTION_SEARCH
            "send" -> EditorInfo.IME_ACTION_SEND
            "next" -> EditorInfo.IME_ACTION_NEXT
            "previous" -> EditorInfo.IME_ACTION_PREVIOUS
            "newline" -> EditorInfo.IME_ACTION_NONE
            else -> EditorInfo.IME_ACTION_DONE
        }

        if (actionCode == EditorInfo.IME_ACTION_NONE) {
            commitText("\n")
        } else {
            currentInputConnection?.performEditorAction(actionCode)
        }
    }

    /**
     * Provide haptic feedback (vibration)
     */
    private fun performHapticFeedback(durationMs: Int, strength: Int) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                val vibrator = vibratorManager?.defaultVibrator
                vibrator?.vibrate(
                    VibrationEffect.createOneShot(
                        durationMs.toLong(),
                        strength.coerceIn(1, 255)
                    )
                )
            } else {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator?.vibrate(
                        VibrationEffect.createOneShot(
                            durationMs.toLong(),
                            strength.coerceIn(1, 255)
                        )
                    )
                } else {
                    @Suppress("DEPRECATION")
                    vibrator?.vibrate(durationMs.toLong())
                }
            }
        } catch (e: Exception) {
            // Silently fail if vibration is not available
        }
    }

    /**
     * Get current editor info as a map
     */
    private fun getEditorInfoMap(): Map<String, Any?> {
        val info = currentEditorInfo ?: return emptyMap()
        return mapOf(
            "inputType" to info.inputType,
            "imeOptions" to info.imeOptions,
            "packageName" to info.packageName,
            "fieldId" to info.fieldId,
            "hintText" to info.hintText?.toString(),
            "label" to info.label?.toString(),
            "actionLabel" to info.actionLabel?.toString(),
            "actionId" to info.actionId,
            "fieldName" to info.fieldName,
            "initialSelStart" to info.initialSelStart,
            "initialSelEnd" to info.initialSelEnd
        )
    }

    /**
     * Cleanup on destroy
     */
    override fun onDestroy() {
        try {
            flutterView?.detachFromFlutterEngine()
        } catch (e: Exception) {
            // Silently handle cleanup errors
        }
        super.onDestroy()
    }
}
