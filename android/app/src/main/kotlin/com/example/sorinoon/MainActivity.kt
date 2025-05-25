package com.example.sorinoon

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var tMapViewInstance: TMapNativeView

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        tMapViewInstance = TMapNativeView(this)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("TMapNativeView", TMapNativeViewFactory { tMapViewInstance })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tmap_channel")
            .setMethodCallHandler { call, result ->
                if (call.method == "drawRoute") {
                    val startLat = call.argument<Double>("startLat") ?: 0.0
                    val startLon = call.argument<Double>("startLon") ?: 0.0
                    val endLat = call.argument<Double>("endLat") ?: 0.0
                    val endLon = call.argument<Double>("endLon") ?: 0.0
                    val routeResult = tMapViewInstance.setRoute(startLat, startLon, endLat, endLon)
                    result.success(routeResult)
                } else {
                    result.notImplemented()
                }
            }
    }
}



