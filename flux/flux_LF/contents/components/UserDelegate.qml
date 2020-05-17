/*
 *   Copyright 2014 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
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

import QtQuick 2.8
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: wrapper
    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    property bool isCurrent: true
    readonly property var m: model
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool constrainText: true
    signal clicked()
    property real faceSize: Math.min(width, height - usernameDelegate.height - units.largeSpacing) * 1.5
    property string shape: "artwork/circle.png"
    state: lockScreenRoot.uiVisible ?"active":"inactive"

    // Draw a translucent background circle under the user picture
    Rectangle{
        id: faceUser
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:  parent.verticalCenter
        color: "transparent"
        width: faceSize
        height: faceSize
        
        Rectangle {
            id: imageSource
            width: faceSize
            height: faceSize
            border.width: 0
            radius: width*0.5
            color:  "#fcfcfc"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            clip: true;

            AnimatedImage {
                id: face
                source: "artwork/gifs/"+wrapper.name+".gif"
                paused: isCurrent ? false : true;
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: faceSize - 2
                height: faceSize  - 2
                smooth: true
                visible: false
            }

            AnimatedImage {
                id: faceIcon
                source: "artwork/gifs/default.gif"
                smooth: true
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                paused:  isCurrent ? false : true;
                width: faceSize - 2
                height: faceSize  - 2
            }

            Image {
                id: mask
                source: shape
                sourceSize: Qt.size(parent.width, parent.height)
                smooth: true
                visible: false
            }

            OpacityMask {
                anchors.fill: face
                source: (face.status == Image.Error || face.status == Image.Null) ? faceIcon : face;
                maskSource: mask
                cached: false
                visible:true
            }

        }
    }

    PlasmaComponents.Label {
        id: usernameDelegate
        anchors {
            top: faceUser.bottom
            horizontalCenter: parent.horizontalCenter;
            margins: 15;

        }
        height: implicitHeight // work around stupid bug in Plasma Components that sets the height
        width: constrainText ? parent.width : implicitWidth
        text: wrapper.name
        elide: Text.ElideRight
        font.underline: wrapper.activeFocus
        color: "#f5f5f5"
        horizontalAlignment: Text.AlignHCenter
        font.capitalization: Font.Capitalize
        font.pointSize: 13
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: wrapper.clicked();
    }

    states: [
        State {
            name: "active"
            PropertyChanges {
                target: imageSource
                scale: 1
            }
            PropertyChanges {
                target: usernameDelegate
                opacity: 1
            }
        },
        State {
            name: "inactive"
            PropertyChanges {
                target: imageSource
                scale: 0
            }
            PropertyChanges {
                target: usernameDelegate
                opacity: 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "inactive"
            to: "active"
            SequentialAnimation {
                ParallelAnimation {
                    ScaleAnimator {
                        target: imageSource
                        from: 0.25
                        to: 1
                        easing.type: Easing.OutBack;
                        duration: 1000
                    }
                    NumberAnimation {
                        target: imageSource
                        property: "opacity"
                        easing.type: Easing.OutQuart
                        duration: 1000
                    }
                }
            }
        },
        Transition {
            from: "active"
            to: "inactive"
            SequentialAnimation {
                ParallelAnimation {
                  ScaleAnimator {
                      target: imageSource//faceUserfaceUser
                      from: 1
                      to: 0
                      easing.type: Easing.InBack//OutQuart;
                      duration: 500
                  }
                  NumberAnimation {
                      target: imageSource//faceUserfaceUser;
                      property: "opacity";
                      easing.type: Easing.OutQuart;
                      duration: 500;
                  }
                }
            }
        }
    ]

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
