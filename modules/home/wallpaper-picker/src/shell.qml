import QtQuick
import Quickshell
import Quickshell.Wayland
import "wallpaper"

PanelWindow {
    id: root
    screen: Quickshell.screens[0]

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-picker-trial"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: "transparent"

    WallpaperPicker {
        id: picker
        anchors.verticalCenter: parent.verticalCenter
        width: root.width
        height: picker.s(650)
        widgetArg: ""

        onCloseRequested: Qt.quit()

        Component.onCompleted: visible = true
    }
}
