import QtQuick
import "../components"

Card {
    id: root

    property var weather: null
    property string iconDir: ""

    readonly property var hours: weather ? weather.hourly : []
    readonly property int visibleColumns: 6

    // The view anchors on an absolute timestamp instead of a pixel offset:
    // when the data window slides forward the card re-aligns to the same
    // moment, so what you scrolled to does not silently drift.
    property real viewAnchorEpoch: 0
    property bool realigning: false

    function firstVisibleIndex() {
        if (!(flick.itemWidth > 0) || hours.length === 0)
            return 0;
        return Math.max(0, Math.min(hours.length - 1, Math.round(flick.contentX / flick.itemWidth)));
    }

    function captureAnchor() {
        const row = hours[firstVisibleIndex()];
        if (row)
            viewAnchorEpoch = row.time;
    }

    function realignToAnchor() {
        if (realigning || viewAnchorEpoch <= 0 || hours.length === 0 || !(flick.itemWidth > 0))
            return;
        let target = 0;
        for (let i = 0; i < hours.length; ++i) {
            if (hours[i].time >= viewAnchorEpoch) {
                target = i;
                break;
            }
            target = i;
        }
        realigning = true;
        flick.contentX = Math.min(target * flick.itemWidth,
                                  Math.max(0, flick.contentWidth - flick.width));
        viewAnchorEpoch = hours[target].time;
        Qt.callLater(function () {
            root.realigning = false;
        });
    }

    onHoursChanged: Qt.callLater(root.realignToAnchor)

    Text {
        id: title

        anchors.left: parent.left
        anchors.top: parent.top
        text: "逐小时预报"
        color: root.textColor
        font.family: "Noto Sans"
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    Flickable {
        id: flick

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: 10

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: Math.max(width, root.hours.length * itemWidth)
        contentHeight: height

        readonly property real itemWidth: width / root.visibleColumns

        onContentXChanged: {
            if (!root.realigning)
                root.captureAnchor();
        }

        Repeater {
            model: root.hours.length

            delegate: Item {
                readonly property var row: root.hours[index] || ({})

                x: index * flick.itemWidth
                width: flick.itemWidth
                height: flick.height

                Text {
                    width: parent.width
                    y: 0
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        const date = new Date(row.time * 1000);
                        return String(date.getHours()).padStart(2, "0") + " 时";
                    }
                    color: root.mutedTextColor
                    font.family: "Noto Sans"
                    font.pixelSize: 12
                }

                MeteoIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 20
                    width: 34
                    height: 34
                    code: row.code === undefined ? -1 : row.code
                    isDay: row.isDay === true
                    iconDir: root.iconDir
                }
            }
        }

        TrendChart {
            id: chart

            y: 66
            width: flick.contentWidth
            height: Math.max(40, flick.height - y - 4)
            values: root.hours.map(function (row) {
                return row.temp;
            })
            valueCount: Math.max(1, root.hours.length)
            lineColor: root.accentColor
            textColor: root.textColor
        }
    }
}
