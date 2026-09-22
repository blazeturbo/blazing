import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

// Frosted: nothing but a name field, a password field, and a way in.
// Frosted-glass card over the blurred wallpaper, one accent, zero chrome:
// no avatar, no session picker (Niri is preselected), no power buttons.
Rectangle {
    id: root
    anchors.fill: parent
    color: "black"

    TextConstants { id: textConstants }
    UserModel { id: userModel }

    property string accent: config.accentColor
    property string ink: config.textColor
    property bool niriFound: false

    // Backup Niri selector (the server default in defaultSession is the
    // first line of defense): scan model roles, pin the Niri session.
    Instantiator {
        model: sessionModel
        delegate: QtObject {
            Component.onCompleted: {
                var n = ((model.name || "") + " " + (model.file || "")).toLowerCase();
                if (n.indexOf("niri") !== -1 && !root.niriFound) {
                    root.niriFound = true;
                    session.index = index;
                }
            }
        }
    }

    function tryLogin() {
        if (nameField.text.length > 0)
            sddm.login(nameField.text, passwordField.text, session.index);
    }

    Component.onCompleted: {
        if (userModel.lastUser !== undefined && userModel.lastUser.length > 0)
            nameField.text = userModel.lastUser;
        entrance.start();
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

    // Center card.
    Rectangle {
        id: card
        width: 340
        height: 264
        anchors.centerIn: parent
        radius: 22
        color: "#8c14161c"
        border.color: "#26ffffff"
        border.width: 1
        opacity: 0
        transform: Translate { id: cardShift }

        SequentialAnimation {
            id: entrance
            NumberAnimation { target: card; property: "opacity"; to: 1; duration: 650; easing.type: Easing.OutCubic }
        }
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
                placeholderText: "name"
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
            }

            TextField {
                id: passwordField
                width: parent.width
                height: 46
                placeholderText: "password"
                echoMode: TextInput.Password
                font.family: config.fontFamily
                font.pointSize: 13
                color: root.ink
                placeholderTextColor: "#80ffffff"
                selectByMouse: true
                KeyNavigation.backtab: nameField
                Keys.onReturnPressed: tryLogin()
                background: Rectangle {
                    radius: 12
                    color: passwordField.activeFocus ? "#2effffff" : "#14ffffff"
                    border.color: passwordField.activeFocus ? root.accent : "transparent"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }
            }

            Button {
                id: loginButton
                width: parent.width
                height: 46
                text: "log in"
                font.family: config.fontFamily
                font.pointSize: 13
                font.capitalization: Font.AllLowercase
                onClicked: tryLogin()
                background: Rectangle {
                    radius: 12
                    color: loginButton.hovered ? Qt.lighter(root.accent, 1.15) : root.accent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: "#14161c"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
