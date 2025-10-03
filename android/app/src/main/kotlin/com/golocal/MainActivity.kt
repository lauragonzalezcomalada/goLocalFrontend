package com.golocal 

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var initialLink: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("MainActivity", "Intent data: ${intent?.data}")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.worldwildprova.deeplink")
            .setMethodCallHandler { call, result ->
                if (call.method == "getInitialLink") {
                    val data: Uri? = intent?.data
                    Log.d("MainActivity", "getInitialLink data: $data")
                    result.success(data?.toString())
                } else {
                    result.notImplemented()
                }
            }
    }
}
