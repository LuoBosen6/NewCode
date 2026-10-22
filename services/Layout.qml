import QtQuick
import Quickshell
import Quickshell.Io

// Persists card positions in layout.json next to shell.qml.
QtObject {
    id: root

    readonly property string filePath: Quickshell.shellDir + "/layout.json"
    property var positions: ({})
    property bool loaded: false

    function load() {
        let data = null;
        try {
            const raw = store.text();
            if (raw && raw.length > 0)
                data = JSON.parse(raw);
        } catch (error) {
            data = null;
        }
        root.positions = (data && typeof data === "object") ? data : ({});
        root.loaded = true;
    }

    function position(id, fallbackX, fallbackY) {
        if (!root.loaded)
            root.load();
        const entry = root.positions[id];
        if (entry && typeof entry.x === "number" && typeof entry.y === "number")
            return {
                "x": entry.x,
                "y": entry.y
            };
        return {
            "x": fallbackX,
            "y": fallbackY
        };
    }

    function place(id, x, y) {
        const next = {};
        for (const key in root.positions)
            next[key] = root.positions[key];
        next[id] = {
            "x": Math.round(x),
            "y": Math.round(y)
        };
        root.positions = next;
        root.save();
    }

    function save() {
        try {
            store.setText(JSON.stringify(root.positions, null, 2) + "\n");
        } catch (error) {
            console.warn("layout save failed: " + error);
        }
    }

    property FileView store: FileView {
        path: root.filePath
        blockLoading: true
        atomicWrites: true
        watchChanges: false
        printErrors: false
    }

    Component.onCompleted: root.load()
}
