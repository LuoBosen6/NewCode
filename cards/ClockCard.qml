import QtQuick
import QtQuick.Effects

// Digital clock, matching the look of the Clavis desktop clock exactly:
// Google Sans Flex (variable, ROND/wdth axes), big primary-coloured hours,
// smaller secondary-coloured minutes with an AM/PM pill, and a letter-spaced
// date underneath. No card background — the glyphs sit straight on the desktop
// with a soft drop shadow.
Item {
    id: root

    property date currentTime: new Date()
    property bool useTwelveHourClock: true

    property color hourColor: "#e9b5ef"
    property color minuteColor: "#d6c0d6"
    property color dateColor: "#eae0e7"
    property color pillColor: "#524153"
    property color pillTextColor: "#f3dbf2"
    property color shadowColor: "#66000000"

    readonly property int hour24: currentTime.getHours()
    readonly property int hour12: ((hour24 + 11) % 12) + 1
    readonly property string hourText: String(root.useTwelveHourClock ? root.hour12 : root.hour24).padStart(2, "0")
    readonly property string minuteText: String(root.currentTime.getMinutes()).padStart(2, "0")
    readonly property string periodText: root.hour24 >= 12 ? "PM" : "AM"
    readonly property string dateText: {
        const weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
        return (root.currentTime.getMonth() + 1) + "月" + root.currentTime.getDate() + "日 "
               + weekdays[root.currentTime.getDay()];
    }

    FontLoader {
        id: clockFont

        source: "../assets/fonts/GoogleSansFlex.ttf"
    }

    readonly property string clockFamily: clockFont.name.length > 0 ? clockFont.name : "Noto Sans"
    readonly property var clockAxes: clockFont.name.length > 0 ? ({
                                                                     "ROND": 25,
                                                                     "wdth": 30
                                                                 }) : ({})

    function topOffset(metrics) {
        return metrics.tightBoundingRect.y - metrics.boundingRect.y;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.currentTime = new Date()
    }

    Item {
        id: face

        readonly property real hourSize: Math.min(284, height * 1.06, width * 0.88)
        readonly property real minuteSize: root.useTwelveHourClock ? Math.min(164, hourSize * 0.61) : hourSize
        readonly property real periodSize: Math.min(26, Math.max(22, height * 0.085))
        readonly property real dateSize: Math.min(32, Math.max(25, height * 0.115))

        anchors.fill: parent

        Item {
            id: composition

            anchors.centerIn: parent
            width: Math.max(glyphGroup.width, dateMetrics.tightBoundingRect.width)
            height: glyphGroup.height + 8 + dateMetrics.tightBoundingRect.height
            layer.enabled: true

            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.shadowColor
                shadowBlur: 0.8
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
                autoPaddingEnabled: true
            }

            Item {
                id: glyphGroup

                readonly property real equalColumnWidth: Math.max(hourMetrics.tightBoundingRect.width,
                                                                  minuteMetrics.tightBoundingRect.width)

                width: root.useTwelveHourClock ? hourMetrics.tightBoundingRect.width + 12 + Math.max(
                                                     minuteMetrics.tightBoundingRect.width,
                                                     periodPill.width) : glyphGroup.equalColumnWidth * 2 + 12
                height: Math.max(hourMetrics.tightBoundingRect.height, minuteMetrics.tightBoundingRect.height
                                 + periodPill.height + 8)

                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: hours

                    x: root.useTwelveHourClock ? -hourMetrics.tightBoundingRect.x : 0
                    y: -root.topOffset(hourMetrics)
                    width: root.useTwelveHourClock ? implicitWidth : glyphGroup.equalColumnWidth
                    text: root.hourText
                    color: root.hourColor
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: root.clockFamily
                        pixelSize: face.hourSize
                        weight: Font.Medium
                        variableAxes: root.clockAxes
                    }
                }

                TextMetrics {
                    id: hourMetrics

                    text: hours.text
                    font: hours.font
                }

                Item {
                    id: minuteColumn

                    width: Math.max(root.useTwelveHourClock ? minuteMetrics.tightBoundingRect.width : glyphGroup.equalColumnWidth,
                                    root.useTwelveHourClock ? periodPill.width : 0)
                    height: minuteMetrics.tightBoundingRect.height + (root.useTwelveHourClock ? periodPill.height + 8 : 0)

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: minutes

                        anchors.left: parent.left
                        y: -root.topOffset(minuteMetrics)
                        width: parent.width
                        text: root.minuteText
                        color: root.minuteColor
                        renderType: Text.NativeRendering
                        horizontalAlignment: Text.AlignHCenter

                        font {
                            family: root.clockFamily
                            pixelSize: face.minuteSize
                            weight: Font.Medium
                            variableAxes: root.clockAxes
                        }
                    }

                    TextMetrics {
                        id: minuteMetrics

                        text: minutes.text
                        font: minutes.font
                    }

                    Rectangle {
                        id: periodPill

                        visible: root.useTwelveHourClock
                        width: periodLabel.implicitWidth + 12
                        height: periodLabel.implicitHeight + 8
                        radius: 8
                        color: root.pillColor

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        Text {
                            id: periodLabel

                            anchors.centerIn: parent
                            text: root.periodText
                            color: root.pillTextColor
                            renderType: Text.NativeRendering

                            font {
                                family: root.clockFamily
                                pixelSize: face.periodSize
                                weight: Font.DemiBold
                                variableAxes: root.clockAxes
                            }
                        }
                    }
                }
            }

            Text {
                id: dateLabel

                width: parent.width
                text: root.dateText
                color: root.dateColor
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                anchors {
                    top: glyphGroup.bottom
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }

                font {
                    family: root.clockFamily
                    pixelSize: face.dateSize
                    weight: Font.DemiBold
                    letterSpacing: 2.4
                    variableAxes: root.clockAxes
                }
            }

            TextMetrics {
                id: dateMetrics

                text: dateLabel.text
                font: dateLabel.font
            }
        }
    }
}
