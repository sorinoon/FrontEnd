package com.example.sorinoon

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var tMapViewInstance: TMapNativeView
    private lateinit var methodChannel: MethodChannel
    private val pendingUserLocation: MutableList<Pair<Double, Double>> = mutableListOf()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tmap_channel")

        tMapViewInstance = TMapNativeView(this, methodChannel)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "TMapNativeView",
                TMapNativeViewFactory { tMapViewInstance }
            )

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "drawRoute" -> {
                    val startLat = call.argument<Double>("startLat") ?: 0.0
                    val startLon = call.argument<Double>("startLon") ?: 0.0
                    val endLat = call.argument<Double>("endLat") ?: 0.0
                    val endLon = call.argument<Double>("endLon") ?: 0.0
                    tMapViewInstance.setRoute(startLat, startLon, endLat, endLon)
                    result.success("경로 설정 완료")
                }

                "updateUserLocation" -> {
                    val lat = call.argument<Double>("latitude")
                    val lon = call.argument<Double>("longitude")
                    if (lat != null && lon != null) {
                        tMapViewInstance.updateUserLocation(lat, lon)
                        result.success("위치 갱신 완료")
                    } else {
                        result.error("INVALID_ARGUMENTS", "위도/경도 누락됨", null)
                    }
                }
                "onMapReady" -> {
                    // Flutter에서 호출할 때 대비용 (실제 동작 안 해도 됨)
                    result.success("ok")
                }


                else -> result.notImplemented()
            }
        }
    }
}
