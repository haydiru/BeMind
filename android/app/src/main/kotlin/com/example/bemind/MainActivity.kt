package com.example.bemind

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private const val CHANNEL = "com.example.bemind/audio_control"
    private var originalNotificationVol: Int = -1
    private var originalSystemVol: Int = -1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "muteSystemAudio" -> {
                    try {
                        if (originalNotificationVol == -1) {
                            originalNotificationVol = audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION)
                            originalSystemVol = audioManager.getStreamVolume(AudioManager.STREAM_SYSTEM)
                        }
                        audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)
                        audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, 0, 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("AUDIO_ERROR", e.message, null)
                    }
                }
                "unmuteSystemAudio" -> {
                    try {
                        if (originalNotificationVol != -1) {
                            audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, originalNotificationVol, 0)
                            audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, originalSystemVol, 0)
                            originalNotificationVol = -1
                            originalSystemVol = -1
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("AUDIO_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
