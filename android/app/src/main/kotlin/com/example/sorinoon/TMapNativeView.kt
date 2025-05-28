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
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.graphics.PixelFormat
import android.graphics.ColorFilter
import android.view.animation.AlphaAnimation
import android.view.ViewGroup


class TMapNativeView(
    private val context: Context,
    private val methodChannel: MethodChannel
) : PlatformView {

    private val tMapView: TMapView = TMapView(context).apply {
        setSKTMapApiKey("huZN3mGcZh2sdd283mTHF8D4AVCBYOVB6v6umT6T")
    }

    private var isMapReady = false

    init {
        tMapView.setOnMapReadyListener {
            isMapReady = true
            Log.d("TMapNativeView", "✅ 지도 준비 완료")
            methodChannel.invokeMethod("onMapReady", null)
        }
    }

    override fun getView(): View = tMapView
    override fun dispose() {}

    // ✅ 실시간 사용자 위치 갱신용 함수
    fun updateUserLocation(lat: Double, lon: Double) {
        if (!isMapReady) {
            Log.w("TMapNativeView", "지도 준비 전. 위치 반영 보류")
            return
        }

        val userPoint = TMapPoint(lat, lon)

        // ✅ 깜빡이는 마커 생성
        val userMarker = TMapMarkerItem().apply {
            id = "user"
            tMapPoint = userPoint
            name = "현재 위치"
            icon = createBlinkingCircle(context)
        }

        // ✅ 기존 마커 제거 후 새 마커 추가
        tMapView.removeTMapMarkerItem("user")
        tMapView.addTMapMarkerItem(userMarker)

        // ✅ 중심 이동 및 줌
        Handler(Looper.getMainLooper()).postDelayed({
            tMapView.setZoomLevel(15)
            tMapView.setLocationPoint(lon, lat)
            tMapView.setCenterPoint(lat, lon) // ← 순서 확인 필요
            tMapView.invalidate()
            Log.d("TMapNativeView", " 강제 좌표 스왑 중심 이동: $lat, $lon")
        }, 800)

        Handler(Looper.getMainLooper()).postDelayed({
            tMapView.setCenterPoint(lat, lon)
            tMapView.invalidate()
            Log.d("TMapNativeView", " 2차 중심 이동 보정 (좌표 스왑): $lat, $lon")
        }, 1800)
    }

    fun createBlinkingCircle(context: Context): Bitmap {
        val size = 100
        val view = View(context).apply {
            layoutParams = ViewGroup.LayoutParams(size, size)
            background = object : Drawable() {
                private val paint = Paint().apply {
                    color = Color.RED
                    alpha = 128
                    isAntiAlias = true
                }

                override fun draw(canvas: Canvas) {
                    val radius = size / 2f
                    canvas.drawCircle(radius, radius, radius, paint)
                }

                override fun setAlpha(alpha: Int) {
                    paint.alpha = alpha
                }

                override fun setColorFilter(colorFilter: ColorFilter?) {}
                override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
            }

            // 깜빡이기
            val alphaAnim = AlphaAnimation(0.3f, 1.0f).apply {
                duration = 800
                repeatMode = AlphaAnimation.REVERSE
                repeatCount = AlphaAnimation.INFINITE
            }
            startAnimation(alphaAnim)
        }

        // 뷰를 비트맵으로 변환
        view.measure(
            View.MeasureSpec.makeMeasureSpec(size, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(size, View.MeasureSpec.EXACTLY)
        )
        view.layout(0, 0, size, size)

        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        view.draw(canvas)

        return bitmap
    }


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
                        println("전체 XML 응답:\n$xmlString")
                    } catch (e: Exception) {
                        println("XML 출력 중 오류: ${e.message}")
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