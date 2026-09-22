import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

// Frosted v2: clock on top, name + password + way in, nothing else.
// Frosted-glass card over the blurred wallpaper, one accent, zero chrome:
// no avatar, no session picker (Niri is preselected), no power buttons.
// Animations: rising entrance with cascading fields, focus glows, a pulse
// on every password keystroke, press states, failed-login shake, live clock.
//
// SDDM API notes (verified against greeter sources + Sugar Candy):
// sessionModel/userModel/config/sddm arrive as context objects (never
// declare them as types). Session index is tracked locally; the login
// call takes it directly, like Sugar Candy's selectedSession.
Rectangle {
    id: root
    anchors.fill: parent
    color: "black"

    property string accent: config.accentColor
    property string ink: config.textColor
    property bool niriFound: false
    property int niriSession: sessionModel.lastIndex

    // Pin the Niri session by scanning model roles. Server-side
    // defaultSession is the first line of defense; this is the second.
    Instantiator {
        model: sessionModel
        delegate: QtObject {
            Component.onCompleted: {
                var n = ((model.name || "") + " " + (model.file || "")).toLowerCase();
                if (!root.niriFound && n.indexOf("niri") !== -1) {
                    root.niriFound = true;
                    root.niriSession = index;
                }
            }
        }
    }

    function fmtClock() {
        var d = new Date();
        var h = d.getHours() % 12;
        if (h === 0) h = 12;
        var m = d.getMinutes();
        timeText.text = h + ":" + (m < 10 ? "0" : "") + m;
        dateText.text = Qt.formatDate(d, "dddd • d MMM").toUpperCase();
    }

    function tryLogin() {
        if (nameField.text.length > 0)
            sddm.login(nameField.text, passwordField.text, root.niriSession);
    }

    Component.onCompleted: {
        if (userModel.lastUser !== undefined && userModel.lastUser.length > 0)
            nameField.text = userModel.lastUser;
        fmtClock();
        entrance.start();
        nameFade.start();
        passFade.start();
        buttonFade.start();
        if (nameField.text.length > 0)
            pwInput.forceActiveFocus();
        else
            nameField.forceActiveFocus();
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = "";
            pwInput.forceActiveFocus();
            shake.start();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: fmtClock()
    }

    // Wallpaper, blurred to frosted glass.
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    FastBlur {
        anchors.fill: wallpaper
        source: wallpaper
        radius: 64
    }
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.35
    }

    // All content rises + fades in as one.
    Column {
        id: content
        anchors.centerIn: parent
        spacing: 40
        opacity: 0
        transform: Translate { id: contentShift }

        SequentialAnimation {
            id: entrance
            ParallelAnimation {
                NumberAnimation { target: content; property: "opacity"; to: 1; duration: 700; easing.type: Easing.OutCubic }
                NumberAnimation { target: contentShift; property: "y"; from: 26; to: 0; duration: 750; easing.type: Easing.OutBack }
            }
        }

        // Clock block.
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: config.fontFamily
                font.pointSize: 92
                font.weight: Font.Light
                color: root.ink
            }
            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: config.fontFamily
                font.pointSize: 15
                color: root.ink
                opacity: 0.65
            }
        }

        // Login card.
        Rectangle {
            id: card
            width: 460
            height: 268
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 22
            color: "#8c14161c"
            border.color: "#26ffffff"
            border.width: 1
            transform: Translate { id: cardShift }

            SequentialAnimation {
                id: shake
                NumberAnimation { target: cardShift; property: "x"; to: -12; duration: 60 }
                NumberAnimation { target: cardShift; property: "x"; to: 12; duration: 60 }
                NumberAnimation { target: cardShift; property: "x"; to: -8; duration: 60 }
                NumberAnimation { target: cardShift; property: "x"; to: 0; duration: 80 }
            }

            Column {
                anchors.centerIn: parent
                width: parent.width - 72
                spacing: 16

                TextField {
                    id: nameField
                    width: parent.width
                    height: 52
                    opacity: 0
                    placeholderText: "name"
                    horizontalAlignment: Text.AlignHCenter
                    font.family: config.fontFamily
                    font.pointSize: 13
                    color: root.ink
                    placeholderTextColor: "#80ffffff"
                    selectByMouse: true
                    KeyNavigation.tab: pwInput
                    Keys.onReturnPressed: {
                        if (nameField.text.length > 0) pwInput.forceActiveFocus();
                    }
                    background: Rectangle {
                        radius: 12
                        color: nameField.activeFocus ? "#2effffff" : "#14ffffff"
                        border.color: nameField.activeFocus ? root.accent : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                    SequentialAnimation {
                        id: nameFade
                        PauseAnimation { duration: 150 }
                        NumberAnimation { target: nameField; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
                    }
                }

                // Custom password display (Caelestia-style): invisible text
                // drives a row of popping dots; native echo unused.
                Item {
                    id: passwordField
                    width: parent.width
                    height: 52
                    opacity: 0
                    property alias text: pwInput.text
                    property int length: pwInput.length

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: pwInput.activeFocus ? "#2effffff" : "#14ffffff"
                        border.color: pwInput.activeFocus ? root.accent : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "password"
                        font.family: config.fontFamily
                        font.pointSize: 13
                        color: "#80ffffff"
                        opacity: pwInput.length > 0 ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    }

                    ListView {
                        anchors.centerIn: parent
                        width: Math.min(contentWidth, parent.width - 32)
                        height: 16
                        clip: true
                        orientation: Qt.Horizontal
                        spacing: 8
                        interactive: false
                        model: pwInput.length
                        delegate: Rectangle {
                            width: 13
                            height: 13
                            anchors.verticalCenter: parent.verticalCenter
                            transformOrigin: Item.Center
                            radius: 6.5
                            color: root.accent
                        }
                        add: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "scale"; from: 0; to: 1; duration: 220; easing.type: Easing.OutBack }
                                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160 }
                            }
                        }
                        displaced: Transition {
                            NumberAnimation { properties: "x,y"; duration: 180; easing.type: Easing.OutCubic }
                        }
                        remove: Transition {
                            ParallelAnimation {
                                NumberAnimation { property: "scale"; to: 0.4; duration: 150 }
                                NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                            }
                        }
                    }

                    TextInput {
                        id: pwInput
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: config.fontFamily
                        font.pointSize: 13
                        color: "transparent"
                        selectionColor: root.accent
                        selectByMouse: true
                        cursorDelegate: Rectangle {
                            width: 2
                            color: "#bfffffff"
                        }
                        KeyNavigation.backtab: nameField
                        Keys.onReturnPressed: tryLogin()
                    }

                    SequentialAnimation {
                        id: passFade
                        PauseAnimation { duration: 260 }
                        NumberAnimation { target: passwordField; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
                    }
                }

                Button {
                    id: loginButton
                    width: parent.width
                    height: 52
                    opacity: 0
                    text: "log in"
                    font.family: config.fontFamily
                    font.pointSize: 13
                    onClicked: tryLogin()
                    background: Rectangle {
                        radius: 12
                        color: loginButton.down ? Qt.darker(root.accent, 1.25) : loginButton.hovered ? Qt.lighter(root.accent, 1.15) : root.accent
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: loginButton.text
                        font: loginButton.font
                        color: "#14161c"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    SequentialAnimation {
                        id: buttonFade
                        PauseAnimation { duration: 370 }
                        NumberAnimation { target: loginButton; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
