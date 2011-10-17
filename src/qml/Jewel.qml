/*
  Copyright 2011 Mats Sjöberg
  
  This file is part of the Heebo programme.
  
  Heebo is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  Heebo is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
  License for more details.
  
  You should have received a copy of the GNU General Public License
  along with Heebo.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.0
import Qt.labs.particles 1.0

Item {
    id: jewel

    width: mainPage.block_width
    height: mainPage.block_height

    z: 0

    property int type: 0;
    property bool spawned: false;
    property bool selected: false;
    property bool to_remove: false;
    property bool dying: false;

    property variant xAnim: xAnimation;
    property variant yAnim: yAnimation;

    Image {
        id: img
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        
        width: jewel.width; height: jewel.width

        source: "qrc:///images/"+(type == 1 ? "circle" :
                                  type == 2 ? "polygon" :
                                  type == 3 ? "square" :
                                  type == 4 ? "triangle_down" :
                                  type == 5 ? "triangle_up" :
                                  "empty")
                                +(mainPage.isRunning && type?"-blink":"")
                                +".png"
        opacity: 1

        Behavior on opacity {
            NumberAnimation { properties:"opacity"; duration: 200 }
        }
    }

    Particles {
        id: particles

        width: 1; height: 1
        anchors.centerIn: parent

        emissionRate: 0
        lifeSpan: 700; lifeSpanDeviation: 600
        angle: 0; angleDeviation: 360;
        velocity: 100; velocityDeviation: 30
        source: "qrc:///images/star.png"
    }

    function moveToBlock(pt) {
        x = pt.x * mainPage.block_width;
        y = pt.y * mainPage.block_height
    }

    function moveToPoint(pt) {
        x = pt.x;
        y = pt.y;
    }

    function animationChanged() {
        if (!yAnimation.running && !xAnimation.running)
            mainPage.animDone();
    }

    function jewelKilled() {
        mainPage.jewelKilled();
    }

    Behavior on y {
        enabled: spawned;
        SmoothedAnimation {
            id: yAnimation
            duration: 500
            onRunningChanged: animationChanged();
        }
    }

    Behavior on x {
        enabled: spawned;
        SmoothedAnimation {
            id: xAnimation
            duration: 500
            onRunningChanged: animationChanged();
        }
    }

    states: [
        State {
            name: "AliveState"
            when: spawned == true && dying == false
            PropertyChanges { target: img; opacity: 1 }
        },
        State {
            name: "DyingState"
            when: dying == true //&& !yAnimation.running && !xAnimation.running

            StateChangeScript { script: particles.burst(50); }
            PropertyChanges { target: img; opacity: 0 }
            StateChangeScript {
                script: { jewel.destroy(1000); jewelKilled(); }
            }
        }
    ]
        
}
