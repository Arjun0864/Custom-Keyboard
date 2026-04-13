package com.flutterboard.keyboard

import android.content.Context
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class FlutterBoardIME : InputMethodService() {

    companion object {
        const val ENGINE_ID = "flutterboard_engine"
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

    override fun onCreate() {
        super.onCreate()
        initializeFlutterEngine()
    }

    private fun initializeFlutterEngine() {
        // Check if engine is already cached
        val existingEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (existingEngine != null) {
            flutterEngine = existingEngine
        } else {
            flutterEngine = FlutterEngine(this).apply {
                dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
                FlutterEngineCache.getInstance().put(ENGINE_ID, this)
            }
        }

        setupMethodChannels()
    }

    private fun setupMethodChannels() {
        val messenger = flutterEngine?.dartExecutor?.binaryMessenger ?: return

        // Main method channel
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL).apply {
            setMethodCallHandler { call, result ->
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
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as android.view.inputmethod.InputMethodManager
                        imm.showInputMethodPicker()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
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

        // Input channel for clipboard and text operations
        inputChannel = MethodChannel(messenger, INPUT_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getClipboardText" -> {
                        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
                        val text = clipboard.primaryClip?.getItemAt(0)?.coerceToText(this@FlutterBoardIME)?.toString()
                        result.success(text)
                    }
                    "setClipboardText" -> {
                        val text = call.argument<String>("text") ?: ""
                        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
                        val clip = android.content.ClipData.newPlainText("FlutterBoard", text)
                        clipboard.setPrimaryClip(clip)
                        result.success(null)
                    }
                    "getSurroundingText" -> {
                        val before = call.argument<Int>("before") ?: 50
                        val after = call.argument<Int>("after") ?: 50
                        val ic = currentInputConnection
                        val textBefore = ic?.getTextBeforeCursor(before, 0)?.toString() ?: ""
                        val textAfter = ic?.getTextAfterCursor(after, 0)?.toString() ?: ""
                        result.success(mapOf("before" to textBefore, "after" to textAfter))
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onCreateInputView(): View {
        flutterView = FlutterView(this).apply {
            attachToFlutterEngine(flutterEngine!!)
        }

        // Notify Flutter that keyboard view is created
        methodChannel?.invokeMethod("onKeyboardCreated", null)

        return flutterView!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        currentEditorInfo = info
        currentInputConnection = this.currentInputConnection

        // Notify Flutter
        methodChannel?.invokeMethod("onStartInput", getEditorInfoMap())

        // Send event
        eventSink?.success(mapOf(
            "type" to "startInput",
            "editorInfo" to getEditorInfoMap()
        ))
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        methodChannel?.invokeMethod("onFinishInput", null)
        eventSink?.success(mapOf("type" to "finishInput"))
    }

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

    // ---- Text Operations ----

    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    private fun deleteBackward() {
        val ic = currentInputConnection ?: return
        val selectedText = ic.getSelectedText(0)
        if (selectedText != null && selectedText.isNotEmpty()) {
            ic.commitText("", 1)
        } else {
            ic.deleteSurroundingText(1, 0)
        }
    }

    private fun deleteForward() {
        currentInputConnection?.deleteSurroundingText(0, 1)
    }

    private fun moveCursor(offset: Int) {
        val ic = currentInputConnection ?: return
        val extracted = ic.getExtractedText(android.view.inputmethod.ExtractedTextRequest(), 0) ?: return
        val newPos = (extracted.selectionStart + offset).coerceIn(0, extracted.text.length)
        ic.setSelection(newPos, newPos)
    }

    private fun selectAll() {
        currentInputConnection?.performContextMenuAction(android.R.id.selectAll)
    }

    private fun getSelectedText(): String? {
        return currentInputConnection?.getSelectedText(0)?.toString()
    }

    private fun setComposingText(text: String) {
        currentInputConnection?.setComposingText(text, 1)
    }

    private fun commitComposingText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    private fun finishComposing() {
        currentInputConnection?.finishComposingText()
    }

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

    private fun performHapticFeedback(durationMs: Int, strength: Int) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                val vibrator = vibratorManager.defaultVibrator
                vibrator.vibrate(
                    VibrationEffect.createOneShot(
                        durationMs.toLong(),
                        strength
                    )
                )
            } else {
                @Suppress("DEPRECATION")
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createOneShot(durationMs.toLong(), strength))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(durationMs.toLong())
                }
            }
        } catch (e: Exception) {
            // Silently fail if vibration is not available
        }
    }

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
        )
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        super.onDestroy()
    }
}
