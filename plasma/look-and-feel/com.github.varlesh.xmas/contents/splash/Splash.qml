/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *   Copyright 2020 modified by Alexey Varfolomeev https://github.com/varlesh/xmas
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

import QtQuick 2.7
import QtQuick.Window 2.2

Item {
    
    Image {
            id: wallpaper
            anchors.centerIn: parent
            source: "images/background.png"
            sourceSize.height: size
            sourceSize.width: size
    }
    
    Rectangle {
    id: snowflake1
    x: 150
    y: 50
    property int stage

        Image {
            id: snf1
            source: "images/snowflake.svg"
            width: 100
            height: 100
            transform: Rotation {
            angle: 45
                
            }
        }
        
    }

    OpacityAnimator {
        id: introAnimation
        running: true
        target: snowflake1
        from: 0
        to: 0.5
        duration: 1000
        easing.type: Easing.InOutQuad
    }
    
    Rectangle {
    id: snowflake2
    x: 480
    y: 530
    
    property int stage

        Image {
            id: snf2
            source: "images/snowflake.svg"
            width: 200
            height: 200
            transform: Rotation {
            angle: 15
                
            }
        }
        
    }

    OpacityAnimator {
        id: introAnimation2
        running: true
        target: snowflake2
        from: 0
        to: 0.8
        duration: 2000
        easing.type: Easing.InOutQuad
    }
    
    Rectangle {
    id: snowflake3
    x: 1000
    y: 300
    property int stage

        Image {
            id: snf3
            source: "images/snowflake.svg"
            width: 150
            height: 150
            transform: Rotation {
            angle: 30
                
            }
        }
        
    }

    OpacityAnimator {
        id: introAnimation3
        running: true
        target: snowflake3
        from: 0
        to: 0.7
        duration: 3000
        easing.type: Easing.InOutQuad
    }
    
    Rectangle {
    id: snowflake4
    x: 1600
    y: 100
    property int stage

        Image {
            id: snf4
            source: "images/snowflake.svg"
            width: 250
            height: 250
            transform: Rotation {
            angle: 70
                
            }
        }
        
    }

    OpacityAnimator {
        id: introAnimation4
        running: true
        target: snowflake4
        from: 0
        to: 0.5
        duration: 4000
        easing.type: Easing.InOutQuad
    }
    
    Rectangle {
    id: snowflake5
    x: 1200
    y: 700
    property int stage

        Image {
            id: snf5
            source: "images/snowflake.svg"
            width: 200
            height: 200
        }
        
    }

    OpacityAnimator {
        id: introAnimation5
        running: true
        target: snowflake5
        from: 0
        to: 1
        duration: 5000
        easing.type: Easing.InOutQuad
    }
    
}
