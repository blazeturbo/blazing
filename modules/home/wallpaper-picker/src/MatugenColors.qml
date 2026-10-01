import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Catppuccin Mocha defaults — used until/unless the Part B matugen hook
    // (gated by ~/.config/hypr/scripts/wallpaper-picker/enable-recolor) writes
    // qs_colors.json.
    property color base: "#1e1e2e"
    property color mantle: "#181825"
    property color crust: "#11111b"
    property color text: "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color subtext1: "#bac2de"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color overlay0: "#6c7086"
    property color overlay1: "#7f849c"
    property color overlay2: "#9399b2"
    property color blue: "#89b4fa"
    property color sapphire: "#74c7ec"
    property color peach: "#fab387"
    property color green: "#a6e3a1"
    property color red: "#f38ba8"
    property color mauve: "#cba6f7"
    property color pink: "#f5c2e7"
    property color yellow: "#f9e2af"
    property color maroon: "#eba0ac"
    property color teal: "#94e2d5"

    property string rawJson: ""

    Process {
        id: themeReader
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/scripts/wallpaper-picker/qs_colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (txt !== "" && txt !== root.rawJson) {
                    root.rawJson = txt;
                    try {
                        let c = JSON.parse(txt);
                        for (let key of ["base", "mantle", "crust", "text", "subtext0", "subtext1",
                                         "surface0", "surface1", "surface2", "overlay0", "overlay1",
                                         "overlay2", "blue", "sapphire", "peach", "green", "red",
                                         "mauve", "pink", "yellow", "maroon", "teal"]) {
                            if (c[key]) root[key] = c[key];
                        }
                    } catch (e) {}
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: themeReader.running = true
    }
}
