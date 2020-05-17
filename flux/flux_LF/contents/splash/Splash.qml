/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0
Rectangle {
    id: root
    color: "#050F1A"
    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true;
        } else if (stage == 7) {
            faces.paused = true
            faces.currentFrame = 0
            introAnimation.target = wrapper;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.duration = 100;
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }
        Rectangle{
            id: wrapper
            anchors.fill : parent
            color: "transparent"
            AnimatedImage {
                id: faces
                source: "images/loader.gif"
                paused: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: true
            }
        }

        DataSource {
            id: timeSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 1000
        }
        Column {
            spacing: units.smallSpacing*2
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                margins: units.gridUnit * 2
            }
            Text {
                text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
                font.pointSize: 40
                renderType: Text.QtRendering
                color: "mintcream"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleLongDate)
                font.pointSize: 22
                renderType: Text.QtRendering
                color: "mintcream"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        
        Row {
            spacing: units.smallSpacing*2
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: units.gridUnit * 2
            }
            Image {
                source: "images/plasma.svgz"
                sourceSize.height: units.gridUnit * 2
                //sourceSize.width: units.gridUnit  * 10
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutQuad
    }
}
