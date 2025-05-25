package com.example.sorinoon

import android.content.Context
import android.graphics.Color
import android.view.View
import com.skt.tmap.TMapData
import com.skt.tmap.TMapPoint
import com.skt.tmap.TMapView
import com.skt.tmap.overlay.TMapMarkerItem
import com.skt.tmap.overlay.TMapPolyLine
import io.flutter.plugin.platform.PlatformView
import android.os.Handler
import android.os.Looper

class TMapNativeView(private val context: Context) : PlatformView {
    private val tMapView: TMapView = TMapView(context).apply {
        setSKTMapApiKey("huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T") // ← 실제 키로 바꾸기
    }

    override fun getView(): View = tMapView
    override fun dispose() {}

    fun setRoute(startLat: Double, startLon: Double, endLat: Double, endLon: Double): String {
        val startPoint = TMapPoint(startLat, startLon)
        val endPoint = TMapPoint(endLat, endLon)

        val startMarker = TMapMarkerItem().apply {
            id = "start"
            tMapPoint = TMapPoint(startLat, startLon)
            name = "출발지"
        }


        val endMarker = TMapMarkerItem().apply {
            id = "end"
            tMapPoint = TMapPoint(endLat, endLon)
            name = "도착지"
        }

        tMapView.removeAllTMapMarkerItem()
        tMapView.addTMapMarkerItem(startMarker)
        tMapView.addTMapMarkerItem(endMarker)
        tMapView.setCenterPoint(startLat, startLon)


        // 도보 경로 표시
        TMapData().findPathData(startPoint, endPoint) { polyline ->
            polyline.lineColor = Color.BLUE
            polyline.lineWidth = 5f
            tMapView.removeAllTMapPolyLine()
            tMapView.addTMapPolyLine(polyline)
        }

        return "경로를 지도에 표시했습니다." // 거리, 시간은 생략
    }

}
