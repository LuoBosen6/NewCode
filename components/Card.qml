import QtQuick

// Rounded translucent card surface shared by every panel.
Rectangle {
    id: root

    property color surfaceColor: "#d9161519"
    property color borderColor: "#33ffffff"
    property color accentColor: "#f2b8e0"
    property color textColor: "#ffffff"
    property color mutedTextColor: "#a8a4ad"
    property int padding: 16

    radius: 24
    color: root.surfaceColor
    border.width: 1
    border.color: root.borderColor
    clip: true

    default property alias content: body.data

    Item {
        id: body

        anchors.fill: parent
        anchors.margins: root.padding
    }
}
