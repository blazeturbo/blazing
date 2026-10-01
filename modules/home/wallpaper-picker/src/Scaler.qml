import QtQuick

Item {
    id: root
    visible: false

    property real currentWidth: 1920.0
    property real currentHeight: currentWidth * (1080.0 / 1920.0)

    // Same shape as imperative-dots' WindowRegistry.getScale(), inlined —
    // no settings.json / uiScale override to watch in this setup.
    property real baseScale: {
        if (currentWidth <= 0 || currentHeight <= 0) return 1.0;
        let rw = currentWidth / 1920.0;
        let rh = currentHeight / 1080.0;
        let r = Math.min(rw, rh);
        return r <= 1.0 ? Math.max(0.35, Math.pow(r, 0.85)) : Math.pow(r, 0.5);
    }

    function s(val) {
        return Math.round(val * baseScale);
    }
}
