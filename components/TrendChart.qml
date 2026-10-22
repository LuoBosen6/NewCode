import QtQuick

// Temperature trend line drawn with Canvas.
// `values` are drawn one column each; column width is width / values.length.
Canvas {
    id: root

    property var values: []
    property color lineColor: "#f2b8e0"
    property color textColor: "#ffffff"
    property int valueCount: Math.max(1, values.length)
    property real columnWidth: width / valueCount
    property string unit: "°"

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onTextColorChanged: requestPaint()

    function pointX(index) {
        return root.columnWidth * index + root.columnWidth / 2;
    }

    function yAt(value, minimum, maximum) {
        if (!(maximum > minimum))
            return root.height / 2;
        // Leave headroom so the temperature labels above points do not clip.
        const top = 18;
        const bottom = root.height - 8;
        return bottom - (value - minimum) / (maximum - minimum) * (bottom - top);
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        const list = [];
        for (let i = 0; i < root.values.length; ++i) {
            const value = Number(root.values[i]);
            if (!isNaN(value))
                list.push(value);
        }
        if (list.length === 0)
            return;

        let minimum = Math.min.apply(null, list);
        let maximum = Math.max.apply(null, list);
        if (maximum - minimum < 1) {
            maximum += 0.5;
            minimum -= 0.5;
        }

        ctx.lineWidth = 2.5;
        ctx.strokeStyle = root.lineColor;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.beginPath();
        for (let i = 0; i < root.values.length; ++i) {
            const value = Number(root.values[i]);
            if (isNaN(value))
                continue;
            const x = pointX(i);
            const y = yAt(value, minimum, maximum);
            if (i === 0)
                ctx.moveTo(x, y);
            else
                ctx.lineTo(x, y);
        }
        ctx.stroke();

        // Dots
        ctx.fillStyle = root.lineColor;
        for (let i = 0; i < root.values.length; ++i) {
            const value = Number(root.values[i]);
            if (isNaN(value))
                continue;
            ctx.beginPath();
            ctx.arc(pointX(i), yAt(value, minimum, maximum), 3.4, 0, Math.PI * 2);
            ctx.fill();
        }

        // Temperature labels
        ctx.fillStyle = root.textColor;
        ctx.font = "600 13px 'Noto Sans'";
        ctx.textAlign = "center";
        ctx.textBaseline = "alphabetic";
        for (let i = 0; i < root.values.length; ++i) {
            const value = Number(root.values[i]);
            if (isNaN(value))
                continue;
            ctx.fillText(Math.round(value) + root.unit, pointX(i),
                         yAt(value, minimum, maximum) - 9);
        }
    }
}
