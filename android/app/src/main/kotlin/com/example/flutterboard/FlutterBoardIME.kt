package com.example.flutterboard

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class FlutterBoardIME : android.inputmethodservice.InputMethodService() {

    companion object {
        const val ENGINE_ID      = "ab_keyboard_engine"
        const val METHOD_CHANNEL = "com.flutterboard/keyboard"
        const val EVENT_CHANNEL  = "com.flutterboard/keyboard_events"
        const val INPUT_CHANNEL  = "com.flutterboard/input"
    }

    private var flutterEngine : FlutterEngine? = null
    private var flutterView   : FlutterView?   = null
    private var rootContainer : FrameLayout?   = null
    private var methodChannel : MethodChannel? = null
    private var inputChannel  : MethodChannel? = null
    private var eventChannel  : EventChannel?  = null
    private var eventSink     : EventChannel.EventSink? = null
    private var currentEditorInfo: EditorInfo? = null

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        initEngine()
    }

    // CRITICAL: Always false — fullscreen mode causes blank white screen
    override fun isFullscreenMode(): Boolean = false

    override fun onCreateInputView(): View {
        if (flutterEngine == null) initEngine()

        // Create FlutterView once and reuse — never detach/reattach
        if (flutterView == null) {
            flutterView = FlutterView(this).apply {
                attachToFlutterEngine(flutterEngine!!)
            }
        }

        // Create container once and reuse
        // WRAP_CONTENT on both dimensions — Flutter dictates the height
        // via its widget tree. This prevents the black gap below the keyboard.
        if (rootContainer == null) {
            rootContainer = FrameLayout(this).apply {
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                )
                addView(
                    flutterView,
                    FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.WRAP_CONTENT
                    )
                )
            }
        }

        return rootContainer!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        currentEditorInfo = info
        val map = editorInfoMap()
        methodChannel?.invokeMethod("onStartInput", map)
        eventSink?.success(mapOf("type" to "startInput", "editorInfo" to map))
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        methodChannel?.invokeMethod("onFinishInput", null)
    }

    override fun onUpdateSelection(
        oldSelStart: Int, oldSelEnd: Int,
        newSelStart: Int, newSelEnd: Int,
        candidatesStart: Int, candidatesEnd: Int
    ) {
        super.onUpdateSelection(
            oldSelStart, oldSelEnd, newSelStart, newSelEnd,
            candidatesStart, candidatesEnd
        )
        eventSink?.success(mapOf(
            "type" to "selectionUpdate",
            "newSelStart" to newSelStart,
            "newSelEnd" to newSelEnd
        ))
    }

    // Do NOT destroy the engine or detach the view — causes blank on next show
    override fun onDestroy() {
        super.onDestroy()
    }

    // ── Engine ────────────────────────────────────────────────────────────────

    private fun initEngine() {
        var engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (engine == null) {
            engine = FlutterEngine(this)
            // Use default entry point → calls main() in lib/main.dart
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        }
        flutterEngine = engine
        setupChannels()
    }

    private fun setupChannels() {
        val messenger = flutterEngine?.dartExecutor?.binaryMessenger ?: return

        methodChannel = MethodChannel(messenger, METHOD_CHANNEL).apply {
            setMethodCallHandler { call, result -> handleMethod(call, result) }
        }
        eventChannel = EventChannel(messenger, EVENT_CHANNEL).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(a: Any?, s: EventChannel.EventSink?) { eventSink = s }
                override fun onCancel(a: Any?) { eventSink = null }
            })
        }
        inputChannel = MethodChannel(messenger, INPUT_CHANNEL).apply {
            setMethodCallHandler { call, result -> handleInput(call, result) }
        }
    }

    // ── Method handlers ───────────────────────────────────────────────────────

    private fun handleMethod(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "commitText"    -> { commitText(call.argument<String>("text") ?: ""); result.success(null) }
            "deleteBackward"-> { deleteBackward(); result.success(null) }
            "deleteForward" -> { currentInputConnection?.deleteSurroundingText(0, 1); result.success(null) }
            "commitAction"  -> { performAction(call.argument<String>("action") ?: "done"); result.success(null) }
            "hideKeyboard"  -> { requestHideSelf(0); result.success(null) }
            "vibrate"       -> {
                vibrate(call.argument<Int>("duration") ?: 30, call.argument<Int>("strength") ?: 128)
                result.success(null)
            }
            "getSelectedText"   -> result.success(currentInputConnection?.getSelectedText(0)?.toString())
            "moveCursor"        -> { moveCursor(call.argument<Int>("offset") ?: 0); result.success(null) }
            "selectAll"         -> { currentInputConnection?.performContextMenuAction(android.R.id.selectAll); result.success(null) }
            "setComposingText"  -> { currentInputConnection?.setComposingText(call.argument<String>("text") ?: "", 1); result.success(null) }
            "finishComposing"   -> { currentInputConnection?.finishComposingText(); result.success(null) }
            "getEditorInfo"     -> result.success(editorInfoMap())
            "isKeyboardMode"    -> result.success(true)
            "setKeyboardHeight" -> result.success(null)
            "switchToPreviousInputMethod" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) switchToPreviousInputMethod()
                result.success(null)
            }
            "showInputMethodPicker" -> {
                (getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager)
                    ?.showInputMethodPicker()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleInput(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "getClipboardText" -> {
                val cb = getSystemService(Context.CLIPBOARD_SERVICE) as? android.content.ClipboardManager
                result.success(
                    try { cb?.primaryClip?.getItemAt(0)?.coerceToText(this)?.toString() }
                    catch (_: Exception) { null }
                )
            }
            "setClipboardText" -> {
                val cb = getSystemService(Context.CLIPBOARD_SERVICE) as? android.content.ClipboardManager
                cb?.setPrimaryClip(
                    android.content.ClipData.newPlainText(
                        "AB Keyboard", call.argument<String>("text") ?: ""
                    )
                )
                result.success(null)
            }
            "getSurroundingText" -> {
                val ic = currentInputConnection
                result.success(mapOf(
                    "before" to (ic?.getTextBeforeCursor(50, 0)?.toString() ?: ""),
                    "after"  to (ic?.getTextAfterCursor(50, 0)?.toString()  ?: "")
                ))
            }
            else -> result.notImplemented()
        }
    }

    // ── Text helpers ──────────────────────────────────────────────────────────

    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    private fun deleteBackward() {
        val ic = currentInputConnection ?: return
        val sel = try { ic.getSelectedText(0) } catch (_: Exception) { null }
        if (!sel.isNullOrEmpty()) ic.commitText("", 1)
        else ic.deleteSurroundingText(1, 0)
    }

    private fun moveCursor(offset: Int) {
        val ic = currentInputConnection ?: return
        try {
            val ex = ic.getExtractedText(android.view.inputmethod.ExtractedTextRequest(), 0) ?: return
            val pos = (ex.selectionStart + offset).coerceIn(0, ex.text.length)
            ic.setSelection(pos, pos)
        } catch (_: Exception) {}
    }

    private fun performAction(action: String) {
        val code = when (action) {
            "done"     -> EditorInfo.IME_ACTION_DONE
            "go"       -> EditorInfo.IME_ACTION_GO
            "search"   -> EditorInfo.IME_ACTION_SEARCH
            "send"     -> EditorInfo.IME_ACTION_SEND
            "next"     -> EditorInfo.IME_ACTION_NEXT
            "previous" -> EditorInfo.IME_ACTION_PREVIOUS
            else       -> EditorInfo.IME_ACTION_DONE
        }
        currentInputConnection?.performEditorAction(code)
    }

    private fun vibrate(durationMs: Int, strength: Int) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                    ?.defaultVibrator
                    ?.vibrate(VibrationEffect.createOneShot(durationMs.toLong(), strength.coerceIn(1, 255)))
            } else {
                @Suppress("DEPRECATION")
                (getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator)?.let { v ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                        v.vibrate(VibrationEffect.createOneShot(durationMs.toLong(), strength.coerceIn(1, 255)))
                    else
                        @Suppress("DEPRECATION") v.vibrate(durationMs.toLong())
                }
            }
        } catch (_: Exception) {}
    }

    private fun editorInfoMap(): Map<String, Any?> {
        val info = currentEditorInfo ?: return emptyMap()
        return mapOf(
            "inputType"       to info.inputType,
            "imeOptions"      to info.imeOptions,
            "packageName"     to info.packageName,
            "hintText"        to info.hintText?.toString(),
            "actionLabel"     to info.actionLabel?.toString(),
            "actionId"        to info.actionId,
            "initialSelStart" to info.initialSelStart,
            "initialSelEnd"   to info.initialSelEnd
        )
    }
}
