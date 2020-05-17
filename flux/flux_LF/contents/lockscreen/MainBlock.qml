/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls.Styles 1.4

import "../components"

SessionManagementScreen {

    property Item mainPasswordBox: passwordBox
    property bool lockScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing
    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    signal loginRequest(string password)


    function startLogin() {
        var password = passwordBox.text
        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(password);
    }

    RowLayout{
        id: centerRow
        Layout.alignment: Qt.AlignHCenter
        Layout.leftMargin: 25
        state: lockScreenRoot.uiVisible ?"active":"inactive"
        states: [
            State {
                name: "active"
                PropertyChanges {
                    target: centerRow
                    opacity: 1
                }
            },
            State {
                name: "inactive"
                PropertyChanges {
                    target: centerRow
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: "inactive"
                to: "active"
                SequentialAnimation {
                    PauseAnimation { duration: 250 }
                    ParallelAnimation {
                        YAnimator {
                            target: centerRow;
                            from: 40
                            to:   0
                            easing.type: Easing.OutQuart
                            duration: 300
                        }
                        NumberAnimation {
                            target: centerRow
                            property: "opacity"
                            duration: 300
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            },
            Transition {
                from: "active"
                to: "inactive"
                SequentialAnimation {
                    ParallelAnimation {
                        YAnimator {
                            target: centerRow;
                            from: 0;
                            to:   40;
                            easing.type: Easing.OutQuart;
                            duration: 500;
                        }
                        NumberAnimation {
                            target: centerRow;
                            property: "opacity";
                            easing.type: Easing.OutQuart;
                            duration: 500;
                        }
                    }
                }
            }
        ]

        PlasmaComponents.TextField {
            id: passwordBox
            Layout.fillWidth: true

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: true
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            enabled: !authenticator.graceLocked
            revealPasswordButtonShown: true
            horizontalAlignment: TextInput.Center
            textColor: "#111111"

            onAccepted: {
                if (lockScreenUiVisible) {
                    startLogin();
                }
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key == Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key == Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: root
                onClearPassword: {
                    passwordBox.forceActiveFocus()
                    passwordBox.selectAll()
                }
            }
            style: TextFieldStyle {
                background: Rectangle {
                    radius: 8
                    color: "#fcfcfc"
                    opacity: 0.7
                }
            }
        }

        Rectangle{
            implicitWidth:  30
            implicitHeight: parent.height
            color: "transparent"
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                id: loginButton
                source: "../components/artwork/go.svgz"
                sourceSize: Qt.size(passwordBox.height, passwordBox.height)
                smooth: true
                opacity: 0.7
            }
            MouseArea {
                anchors.fill: parent
                onClicked: startLogin();
            }
        }
    }
}
