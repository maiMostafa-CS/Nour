package com.example.islamic_app

import android.content.Context
import android.util.AttributeSet
import android.widget.ScrollView

/**
 * ScrollView with dynamic maximum height constraint.
 * If content height exceeds maxHeight, it caps its height to maxHeight and scrolls.
 * If content height is smaller than maxHeight, it wraps content naturally.
 */
class MaxHeightScrollView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : ScrollView(context, attrs, defStyleAttr) {

    var maxHeight: Int = 0
        set(value) {
            field = value
            requestLayout()
        }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        var adjustedHeightSpec = heightMeasureSpec
        if (maxHeight > 0) {
            val mode = MeasureSpec.getMode(heightMeasureSpec)
            val size = MeasureSpec.getSize(heightMeasureSpec)
            val targetSize = if (mode == MeasureSpec.UNSPECIFIED || size == 0) {
                maxHeight
            } else {
                minOf(size, maxHeight)
            }
            adjustedHeightSpec = MeasureSpec.makeMeasureSpec(targetSize, MeasureSpec.AT_MOST)
        }
        super.onMeasure(widthMeasureSpec, adjustedHeightSpec)
    }
}
