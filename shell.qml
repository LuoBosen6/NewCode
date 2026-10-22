import QtQuick
import Quickshell
import Quickshell.Wayland
import "cards"
import "components"
import "services"

// A minimal, self-contained desktop card set: clock, current weather, daily
// forecast and hourly forecast. Drawn on a full-screen Bottom layer surface so
// it sits behind normal windows, with input enabled only where it is needed.
ShellRoot {
    id: shell

    Weather {
        id: weatherService

        latitude: 38.94755
        longitude: 118.55078
        locationName: "曹妃甸"
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

            // Only the hourly card needs pointer input (horizontal scrolling);
            // everything else lets clicks fall through to the desktop.
            mask: Region {
                Region {
                    item: hourlyCard
                }
            }

            Item {
                id: layout

                anchors.fill: parent

                ClockCard {
                    id: clockCard

                    width: 400
                    height: 190
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 40
                    anchors.topMargin: 30
                }

                WeatherNowCard {
                    id: nowCard

                    width: 300
                    height: 150
                    weather: weatherService
                    iconDir: shell.iconDir
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 40
                    anchors.bottomMargin: 40
                }

                DailyForecastCard {
                    id: dailyCard

                    width: 430
                    height: 180
                    weather: weatherService
                    iconDir: shell.iconDir
                    anchors.left: parent.left
                    anchors.bottom: hourlyCard.top
                    anchors.leftMargin: 40
                    anchors.bottomMargin: 20
                }

                HourlyForecastCard {
                    id: hourlyCard

                    width: 470
                    height: 300
                    weather: weatherService
                    iconDir: shell.iconDir
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 40
                    anchors.bottomMargin: 40
                }
            }
        }
    }
}
