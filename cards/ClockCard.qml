import QtQuick
import "../components"

Card {
    id: root

    property var now: new Date()

    property string timeText: {
        const hours = String(root.now.getHours()).padStart(2, "0");
        const minutes = String(root.now.getMinutes()).padStart(2, "0");
        return hours + ":" + minutes;
    }

    property string dateText: {
        const weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
        const date = root.now;
        return (date.getMonth() + 1) + "月" + date.getDate() + "日 " + weekdays[date.getDay()];
    }

    // Ticks once a second; cheap, and keeps the clock honest across suspend.
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 2

        Text {
            text: root.timeText
            color: root.accentColor
            font.family: "Noto Sans"
            font.pixelSize: 64
            font.weight: Font.DemiBold
            lineHeight: 0.9
        }

        Text {
            text: root.dateText
            color: root.mutedTextColor
            font.family: "Noto Sans"
            font.pixelSize: 15
        }
    }
}
