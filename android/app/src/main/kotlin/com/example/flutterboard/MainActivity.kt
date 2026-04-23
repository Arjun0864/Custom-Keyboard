package com.example.flutterboard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Launcher activity — shows the settings screen.
 * Uses the "settingsMain" Dart entry point so it never shows the keyboard UI.
 */
class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: android.content.Context): FlutterEngine {
        return FlutterEngine(context).apply {
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault().also {
                    // Use settingsMain() entry point defined in lib/main.dart
                },
            )
        }
    }

    override fun getDartEntrypointFunctionName(): String = "settingsMain"
}
