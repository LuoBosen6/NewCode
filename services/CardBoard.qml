import QtQuick

// Resolves overlaps between cards by pushing the overlapped card away along
// the axis of least penetration, repeating for cards that get pushed into
// others. Positions are clamped to the screen, so a card that cannot be pushed
// any further just stays where it is (worst case: overlap remains).
QtObject {
    id: root

    property var layout: null
    property var items: []
    property real gap: 12

    function register(item) {
        const next = [];
        for (let i = 0; i < root.items.length; ++i)
            next.push(root.items[i]);
        if (next.indexOf(item) === -1)
            next.push(item);
        root.items = next;
    }

    function bounds() {
        const parent = root.items.length > 0 ? root.items[0].parent : null;
        return {
            "width": parent ? parent.width : 0,
            "height": parent ? parent.height : 0
        };
    }

    function pushVector(source, target) {
        const sx1 = source.posX;
        const sy1 = source.posY;
        const sx2 = sx1 + source.width;
        const sy2 = sy1 + source.height;
        const tx1 = target.posX;
        const ty1 = target.posY;
        const tx2 = tx1 + target.width;
        const ty2 = ty1 + target.height;

        const overlapX = Math.min(sx2, tx2) - Math.max(sx1, tx1);
        const overlapY = Math.min(sy2, ty2) - Math.max(sy1, ty1);
        if (overlapX <= 0 || overlapY <= 0)
            return null;

        if (overlapX < overlapY) {
            const dx = (tx1 + tx2) >= (sx1 + sx2) ? overlapX + root.gap : -(overlapX + root.gap);
            return {
                "dx": dx,
                "dy": 0
            };
        }
        const dy = (ty1 + ty2) >= (sy1 + sy2) ? overlapY + root.gap : -(overlapY + root.gap);
        return {
            "dx": 0,
            "dy": dy
        };
    }

    function clampItem(item) {
        const size = root.bounds();
        const maxX = Math.max(0, size.width - item.width);
        const maxY = Math.max(0, size.height - item.height);
        item.posX = Math.max(0, Math.min(maxX, item.posX));
        item.posY = Math.max(0, Math.min(maxY, item.posY));
    }

    // `movedId` is the card the user just dropped; everything else is pushed.
    function resolve(movedId) {
        const moved = root.items.find(function (item) {
            return item.cardId === movedId;
        });
        if (!moved)
            return;

        // Breadth-first: the dropped card pushes its neighbours, which may in
        // turn push theirs, so a cluster gets separated in one go.
        const queue = [moved];
        const visited = [moved];
        let guard = 0;

        while (queue.length > 0 && guard++ < 40) {
            const source = queue.shift();
            for (let i = 0; i < root.items.length; ++i) {
                const target = root.items[i];
                if (target === source || visited.indexOf(target) !== -1)
                    continue;
                const push = root.pushVector(source, target);
                if (!push)
                    continue;
                target.posX += push.dx;
                target.posY += push.dy;
                root.clampItem(target);
                visited.push(target);
                queue.push(target);
            }
        }

        root.saveAll();
    }

    function saveAll() {
        if (!root.layout)
            return;
        const next = {};
        for (let i = 0; i < root.items.length; ++i) {
            const item = root.items[i];
            next[item.cardId] = {
                "x": Math.round(item.posX),
                "y": Math.round(item.posY)
            };
        }
        root.layout.positions = next;
        root.layout.save();
    }
}
