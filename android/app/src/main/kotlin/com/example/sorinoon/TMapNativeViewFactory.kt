package com.example.sorinoon

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

object TMapViewHolder {
    var instance: TMapNativeView? = null
}

class TMapNativeViewFactory(
    private val viewProvider: () -> TMapNativeView
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return viewProvider()
    }
}
