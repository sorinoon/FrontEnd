package com.example.sorinoon

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import com.skt.tmap.TMapPoint
import com.skt.tmap.TMapView
import com.skt.tmap.TMapData
import com.skt.tmap.TMapData.TMapPathType
import com.skt.tmap.TMapData.OnFindPathDataAllTypeListener
import com.skt.tmap.overlay.TMapMarkerItem
import com.skt.tmap.overlay.TMapPolyLine
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.common.MethodChannel
import org.w3c.dom.Document
import org.w3c.dom.Node
import java.io.StringWriter
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import android.util.Log






class TMapNativeView(
    private val context: Context,
    private val methodChannel: MethodChannel
) : PlatformView {

    private val tMapView: TMapView = TMapView(context).apply {
        setSKTMapApiKey("huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T")
    }

    override fun getView(): View = tMapView
    override fun dispose() {}

    fun setRoute(startLat: Double, startLon: Double, endLat: Double, endLon: Double) {
        if (tMapView == null) {
            Log.e("TMapNativeView", "tMapView가 아직 초기화되지 않았습니다.")
            return
        }

        tMapView?.removeAllTMapMarkerItem()
        val startPoint = TMapPoint(startLat, startLon)
        val endPoint = TMapPoint(endLat, endLon)

        val startMarker = TMapMarkerItem().apply {
            id = "start"
            tMapPoint = startPoint
            name = "출발지"
        }

        val endMarker = TMapMarkerItem().apply {
            id = "end"
            tMapPoint = endPoint
            name = "도착지"
        }

        tMapView.removeAllTMapMarkerItem()
        tMapView.addTMapMarkerItem(startMarker)
        tMapView.addTMapMarkerItem(endMarker)
        tMapView.setCenterPoint(startLat, startLon)

        Handler(Looper.getMainLooper()).postDelayed({
            tMapView.setCenterPoint(startLon, startLat)
        }, 500)

        val tMapData = TMapData()
        tMapData.findPathDataAllType(
            TMapData.TMapPathType.PEDESTRIAN_PATH,
            startPoint,
            endPoint,
            object : TMapData.OnFindPathDataAllTypeListener {
                override fun onFindPathDataAllType(result: Document?) {
                    try {
                        val transformer = TransformerFactory.newInstance().newTransformer()
                        val writer = StringWriter()
                        transformer.transform(DOMSource(result), StreamResult(writer))
                        val xmlString = writer.toString()
                        println("🔍 전체 XML 응답:\n$xmlString")
                    } catch (e: Exception) {
                        println("❌ XML 출력 중 오류: ${e.message}")
                    }
                    if (result != null) {
                        val polyline = TMapPolyLine()
                        val nodeList = result.getElementsByTagName("LineString")
                        for (i in 0 until nodeList.length) {
                            val coords = nodeList.item(i).textContent.trim().split(" ")
                            for (coord in coords) {
                                val lonLat = coord.split(",")
                                if (lonLat.size >= 2) {
                                    val lon = lonLat[0].toDouble()
                                    val lat = lonLat[1].toDouble()
                                    polyline.addLinePoint(TMapPoint(lat, lon))
                                }
                            }
                        }

                        var totalSeconds = 0
                        val timeNodeList = result.getElementsByTagName("tmap:totalTime")
                        if (timeNodeList.length > 0) {
                            val timeNode = timeNodeList.item(0)
                            val timeStr = timeNode.textContent
                            println("🟡 totalTime 태그 내용: $timeStr") // 로그 추가
                            totalSeconds = timeStr.toIntOrNull() ?: 0
                        }

                        TMapData().findPathData(startPoint, endPoint) { nativePolyline ->
                            nativePolyline.lineColor = Color.BLUE
                            nativePolyline.lineWidth = 5f
                            tMapView.removeAllTMapPolyLine()
                            tMapView.addTMapPolyLine(nativePolyline)

                            val minutes = totalSeconds / 60
                            val timeText = "도보 예상 시간: ${minutes}분"
                            Handler(Looper.getMainLooper()).post {
                                methodChannel.invokeMethod("routeResult", timeText)
                            }
                        }

                    } else {
                        Handler(Looper.getMainLooper()).post {
                            methodChannel.invokeMethod("routeResult", "경로 정보를 불러올 수 없습니다.")
                        }
                    }
                }
            }
        )
    }
}

