import QtQuick

// Wraps a card and makes it draggable by its header strip (or anywhere, for
// cards with no interactive content). Position is remembered through `layout`.
Item {
    id: root

    property string cardId: ""
    property var layout: null
    property bool dragAnywhere: false
    property real dragBarHeight: 46
    property real defaultX: 0
    property real defaultY: 0

    property real posX: root.defaultX
    property real posY: root.defaultY
    property point pressPoint: Qt.point(0, 0)
    property point pressPos: Qt.point(0, 0)

    default property alias content: inner.data

    x: root.posX
    y: root.posY
    z: dragArea.pressed ? 100 : 0

    Item {
        id: inner

        anchors.fill: parent
    }

    MouseArea {
        id: dragArea

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.dragAnywhere ? root.height : Math.min(root.dragBarHeight, root.height)
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: function (mouse) {
            root.pressPoint = dragArea.mapToItem(root.parent, mouse.x, mouse.y);
            root.pressPos = Qt.point(root.posX, root.posY);
        }

        onPositionChanged: function (mouse) {
            if (!pressed)
                return;
            const current = dragArea.mapToItem(root.parent, mouse.x, mouse.y);
            const maxX = Math.max(0, root.parent.width - root.width);
            const maxY = Math.max(0, root.parent.height - root.height);
            root.posX = Math.max(0, Math.min(maxX, root.pressPos.x + current.x - root.pressPoint.x));
            root.posY = Math.max(0, Math.min(maxY, root.pressPos.y + current.y - root.pressPoint.y));
        }

        onReleased: {
            if (root.layout)
                root.layout.place(root.cardId, root.posX, root.posY);
        }
    }

    Component.onCompleted: {
        if (!root.layout)
            return;
        const saved = root.layout.position(root.cardId, root.defaultX, root.defaultY);
        root.posX = saved.x;
        root.posY = saved.y;
    }
}
