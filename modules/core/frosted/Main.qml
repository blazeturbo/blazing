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
        ampmText.text = d.getHours() < 12 ? "AM" : "PM";
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
            passwordField.forceActiveFocus();
        else
            nameField.forceActiveFocus();
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.text = "";
            passwordField.forceActiveFocus();
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
                NumberAnimation { target: contentShift; property: "y"; from: 26; to: 0; duration: 700; easing.type: Easing.OutCubic }
            }
        }

        // Clock block.
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Text {
                    id: timeText
                    font.family: config.fontFamily
                    font.pointSize: 92
                    font.weight: Font.Light
                    color: root.ink
                }
                Text {
                    id: ampmText
                    anchors.baseline: timeText.baseline
                    font.family: config.fontFamily
                    font.pointSize: 26
                    font.weight: Font.DemiBold
                    color: root.accent
                }
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
            width: 360
            height: 250
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
                width: parent.width - 64
                spacing: 14

                TextField {
                    id: nameField
                    width: parent.width
                    height: 46
                    opacity: 0
                    placeholderText: "name"
                    horizontalAlignment: Text.AlignHCenter
                    font.family: config.fontFamily
                    font.pointSize: 13
                    color: root.ink
                    placeholderTextColor: "#80ffffff"
                    selectByMouse: true
                    KeyNavigation.tab: passwordField
                    Keys.onReturnPressed: {
                        if (nameField.text.length > 0) passwordField.forceActiveFocus();
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

                TextField {
                    id: passwordField
                    width: parent.width
                    height: 46
                    opacity: 0
                    placeholderText: "password"
                    horizontalAlignment: Text.AlignHCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "·"
                    font.family: config.fontFamily
                    font.pointSize: 13
                    color: root.ink
                    placeholderTextColor: "#80ffffff"
                    selectByMouse: true
                    KeyNavigation.backtab: nameField
                    Keys.onReturnPressed: tryLogin()
                    onTextChanged: pwPulse.restart()
                    transformOrigin: Item.Center
                    transform: Scale { id: pwScale }
                    background: Rectangle {
                        radius: 12
                        color: passwordField.activeFocus ? "#2effffff" : "#14ffffff"
                        border.color: passwordField.activeFocus ? root.accent : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                    SequentialAnimation {
                        id: passFade
                        PauseAnimation { duration: 260 }
                        NumberAnimation { target: passwordField; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
                    }
                    SequentialAnimation {
                        id: pwPulse
                        ParallelAnimation {
                            NumberAnimation { target: pwScale; property: "xScale"; to: 1.025; duration: 70 }
                            NumberAnimation { target: pwScale; property: "yScale"; to: 1.025; duration: 70 }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: pwScale; property: "xScale"; to: 1.0; duration: 110 }
                            NumberAnimation { target: pwScale; property: "yScale"; to: 1.0; duration: 110 }
                        }
                    }
                }

                Button {
                    id: loginButton
                    width: parent.width
                    height: 46
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
