import QtQuick
import "../components"

Card {
    id: root

    property var weather: null
    property string iconDir: ""

    readonly property var current: weather ? weather.current : ({})
    readonly property bool isDay: {
        const rows = weather ? weather.hourly : [];
        return rows.length > 0 ? rows[0].isDay : true;
    }

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.current.temp === undefined ? "--" : Math.round(root.current.temp) + "°"
            color: root.textColor
            font.family: "Noto Sans"
            font.pixelSize: 56
            font.weight: Font.DemiBold
        }

        MeteoIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 64
            code: root.current.code === undefined ? -1 : root.current.code
            isDay: root.isDay
            iconDir: root.iconDir
        }
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 4

        Text {
            text: root.weather ? root.weather.locationName : ""
            color: root.mutedTextColor
            font.family: "Noto Sans"
            font.pixelSize: 13
        }

        Text {
            text: {
                if (!root.weather || root.current.temp === undefined)
                    return "";
                const feels = root.current.feels === undefined ? "" : "体感 " + Math.round(root.current.feels) + "°  ";
                const humidity = root.current.humidity === undefined ? "" : "湿度 " + Math.round(root.current.humidity) + "%  ";
                const wind = root.current.wind === undefined ? "" : "风 " + root.current.wind.toFixed(1) + " m/s";
                return feels + humidity + wind;
            }
            color: root.textColor
            font.family: "Noto Sans"
            font.pixelSize: 13
        }
    }
}
