import QtQuick
import "../components"

Card {
    id: root

    property var weather: null
    property string iconDir: ""

    readonly property var days: weather ? weather.daily : []

    Row {
        id: topRow

        anchors.left: parent.left
        anchors.top: parent.top
        spacing: 6

        Text {
            text: "每日预报"
            color: root.textColor
            font.family: "Noto Sans"
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topRow.bottom
        anchors.topMargin: 12
        spacing: 4

        Repeater {
            model: root.days.length

            delegate: Column {
                readonly property var day: root.days[index] || ({})

                width: (root.width - root.padding * 2 - 4 * (root.days.length - 1)) / Math.max(1, root.days.length)
                spacing: 6

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if (index === 0)
                            return "今天";
                        const date = new Date(day.time * 1000);
                        const weekdays = ["日", "一", "二", "三", "四", "五", "六"];
                        return "周" + weekdays[date.getDay()];
                    }
                    color: root.mutedTextColor
                    font.family: "Noto Sans"
                    font.pixelSize: 12
                }

                MeteoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 34
                    height: 34
                    code: day.code === undefined ? -1 : day.code
                    isDay: true
                    iconDir: root.iconDir
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: (day.high === undefined ? "--" : Math.round(day.high)) + "°"
                    color: root.textColor
                    font.family: "Noto Sans"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: (day.low === undefined ? "--" : Math.round(day.low)) + "°"
                    color: root.mutedTextColor
                    font.family: "Noto Sans"
                    font.pixelSize: 12
                }
            }
        }
    }
}
