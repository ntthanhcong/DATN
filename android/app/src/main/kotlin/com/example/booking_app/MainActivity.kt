package com.example.booking_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
  private val DEEP_LINK_CHANNEL = "com.example.booking_app/deep_link_stream"
  private var eventSink: EventChannel.EventSink? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    EventChannel(flutterEngine.dartExecutor.binaryMessenger, DEEP_LINK_CHANNEL).setStreamHandler(
      object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
          eventSink = sink
          // Cold start: gửi ngay deep link nếu app được khởi động từ link
          val initialLink = intent?.dataString
          if (initialLink != null) sink?.success(initialLink)
        }
        override fun onCancel(arguments: Any?) {
          eventSink = null
        }
      }
    )
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    // Warm start: app đang chạy, MoMo gọi onNewIntent
    val link = intent.dataString
    if (link != null) {
      eventSink?.success(link)
    }
  }
}
