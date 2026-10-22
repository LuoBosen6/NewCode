import QtQuick

// Maps Open-Meteo weather codes to meteocons SVG slugs, day/night aware.
// Assets are the `fill` style: assets/weather/<slug>.svg
Item {
    id: root

    property int code: -1
    property bool isDay: true
    property string iconDir: ""

    readonly property string slug: {
        const night = !isDay;
        if (code === 0) return night ? "clear-night" : "clear-day";
        if (code === 1) return night ? "mostly-clear-night" : "mostly-clear-day";
        if (code === 2) return night ? "partly-cloudy-night" : "partly-cloudy-day";
        if (code === 3) return "cloudy";
        if (code === 45 || code === 48) return night ? "fog-night" : "fog-day";
        if (code >= 51 && code <= 57) return "drizzle";
        if (code === 61 || code === 63 || code === 65) return night ? "overcast-night-rain" : "overcast-day-rain";
        if (code === 66 || code === 67) return night ? "overcast-night-sleet" : "overcast-day-sleet";
        if (code >= 71 && code <= 77) return night ? "overcast-night-snow" : "overcast-day-snow";
        if (code >= 80 && code <= 82) return night ? "partly-cloudy-night-rain" : "partly-cloudy-day-rain";
        if (code === 85 || code === 86) return night ? "partly-cloudy-night-snow" : "partly-cloudy-day-snow";
        if (code === 95) return night ? "thunderstorms-night" : "thunderstorms-day";
        if (code === 96 || code === 99) return night ? "thunderstorms-night-hail" : "thunderstorms-day-hail";
        return "not-available";
    }

    readonly property string summary: {
        if (code === 0) return "晴";
        if (code === 1) return "少云";
        if (code === 2) return "多云";
        if (code === 3) return "阴";
        if (code === 45 || code === 48) return "雾";
        if (code >= 51 && code <= 57) return "毛毛雨";
        if (code === 61) return "小雨";
        if (code === 63) return "中雨";
        if (code === 65) return "大雨";
        if (code === 66 || code === 67) return "冻雨";
        if (code >= 71 && code <= 77) return "雪";
        if (code >= 80 && code <= 82) return "阵雨";
        if (code === 85 || code === 86) return "阵雪";
        if (code === 95) return "雷雨";
        if (code === 96 || code === 99) return "雷暴冰雹";
        return "未知";
    }

    implicitWidth: 48
    implicitHeight: 48

    Image {
        anchors.fill: parent
        source: root.iconDir + "/" + root.slug + ".svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        sourceSize.width: Math.max(1, Math.round(width * 2))
        sourceSize.height: Math.max(1, Math.round(height * 2))
    }
}
