package com.example.sound_center

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.channel.audio_delete"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "deleteAudio") {
                val uriString = call.argument<String>("uri")
                if (uriString != null) {
                    val uri = Uri.parse(uriString)
                    val deleted = deleteAudioFile(uri)
                    result.success(deleted)
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun deleteAudioFile(uri: Uri): Boolean {
        return try {
            contentResolver.delete(uri, null, null) > 0
        } catch (e: Exception) {
            false
        }
    }
}
