import QtQuick
import Quickshell
import Quickshell.Wayland
import "cards"
import "components"
import "services"

// A minimal, self-contained desktop card set: clock, current weather, daily
// forecast and hourly forecast. Drawn on a full-screen Bottom layer surface so
// it sits behind normal windows; cards are draggable by their header strip and
// their positions persist in layout.json.
ShellRoot {
    id: shell

    Weather {
        id: weatherService

        latitude: 38.94755
        longitude: 118.55078
        locationName: "曹妃甸"
    }

    Layout {
        id: layout
    }

    readonly property string iconDir: Qt.resolvedUrl("assets/weather").toString()

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData
            property var monitor: modelData

            screen: window.monitor
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "newcode-cards"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            // Cards need pointer input for dragging (and the hourly card for
            // horizontal scrolling); everything else falls through.
            mask: Region {
                Region {
                    item: clockWrap
                }

                Region {
                    item: nowWrap
                }

                Region {
                    item: dailyWrap
                }

                Region {
                    item: hourlyWrap
                }
            }

            Item {
                id: layoutRoot

                anchors.fill: parent

                DraggableCard {
                    id: clockWrap

                    cardId: "clock"
                    layout: layout
                    dragAnywhere: true
                    width: 440
                    height: 190
                    defaultX: layoutRoot.width - width - 40
                    defaultY: 30

                    ClockCard {
                        anchors.fill: parent
                    }
                }

                DraggableCard {
                    id: nowWrap

                    cardId: "now"
                    layout: layout
                    dragAnywhere: true
                    width: 320
                    height: 160
                    defaultX: layoutRoot.width - width - 40
                    defaultY: layoutRoot.height - height - 40

                    WeatherNowCard {
                        anchors.fill: parent
                        weather: weatherService
                        iconDir: shell.iconDir
                    }
                }

                DraggableCard {
                    id: dailyWrap

                    cardId: "daily"
                    layout: layout
                    dragBarHeight: 44
                    width: 430
                    height: 180
                    defaultX: 40
                    defaultY: layoutRoot.height - height - 40 - hourlyWrap.height - 20

                    DailyForecastCard {
                        anchors.fill: parent
                        weather: weatherService
                        iconDir: shell.iconDir
                    }
                }

                DraggableCard {
                    id: hourlyWrap

                    cardId: "hourly"
                    layout: layout
                    dragBarHeight: 44
                    width: 470
                    height: 300
                    defaultX: 40
                    defaultY: layoutRoot.height - height - 40

                    HourlyForecastCard {
                        anchors.fill: parent
                        weather: weatherService
                        iconDir: shell.iconDir
                    }
                }
            }
        }
    }
}
