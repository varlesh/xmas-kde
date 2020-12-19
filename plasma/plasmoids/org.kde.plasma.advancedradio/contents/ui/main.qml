
/***************************************************************************
*   Copyright (C) 2019 by Dr_i-glu4IT <dr@i-glu4it.ru>     *
***************************************************************************/
import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtMultimedia 5.8
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 as QQC2

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.centerIn: parent

    width: 220
    height: 300
    ServersModel {
        id: serversModel
    }

    PlasmaCore.DataSource {
        id: notificationSource
        engine: "notifications"
        connectedSources: "org.freedesktop.Notifications"
    }

    Component.onCompleted: {
        playMusic.stop()
        playMusic.source = ''
        reloadServerModel()
    }

    Connections {
        target: plasmoid.configuration
        onServersChanged: {
            playMusic.stop()
            playMusic.source = ''
            reloadServerModel()
        }
    }

    Item {
        id: tool

        property int preferredTextWidth: units.gridUnit * 20
        Layout.minimumWidth: childrenRect.width + units.gridUnit
        Layout.minimumHeight: childrenRect.height + units.gridUnit
        Layout.maximumWidth: childrenRect.width + units.gridUnit
        Layout.maximumHeight: childrenRect.height + units.gridUnit

        RowLayout {

            anchors {
                left: parent.left
                top: parent.top
                margins: units.gridUnit / 2
            }

            spacing: units.largeSpacing
            Image {
                id: tooltipImage
                source: root.imgurl
                visible: tool != null && tool.image != ""
                Layout.alignment: Qt.AlignTop
                width: 80
                ColorOverlay {
                    anchors.fill: tooltipImage
                    source: tooltipImage
                    color: PlasmaCore.ColorScope.textColor
                    visible: !root.imgurl.startsWith("http")
                    antialiasing: true
                }
            }

            ColumnLayout {
                PlasmaExtras.Heading {
                    id: tooltipMaintext
                    level: 3
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    text: root.title
                    visible: text != ""
                }
                PlasmaComponents.Label {
                    id: tooltipSubtext
                    Layout.fillWidth: true
                    height: undefined
                    wrapMode: Text.WordWrap
                    text: root.subtitle
                    opacity: 0.8
                    visible: text != ""
                    maximumLineCount: 8
                }
            }
        }
    }

    property bool notification: plasmoid.configuration.Notification
    property bool transback: plasmoid.configuration.transback
    property string title: i18n("Advanced Radio Player")
    property string subtitle: i18n("Choose station")
    property string imgurl: isPlaying(
                                ) ? "../images/unknown.svg" : "../images/blank.svg"
    property color textColor: plasmoid.location == PlasmaCore.Types.Floating
                              && plasmoid.configuration.transback ? plasmoid.configuration.fontColor : PlasmaCore.ColorScope.textColor
    property string imglocal
    onSubtitleChanged: {
        root.notification == true ? title != i18n("Advanced Radio Player")
                                    && title != i18n(
                                        "Unknown Artist") ? createNotification(
                                                                ) : '' : ''
    }
    Plasmoid.backgroundHints: plasmoid.configuration.transback ? "NoBackground" : "DefaultBackground"

    MediaPlayer {
        id: playMusic
        onError: {

            playMusic.stop()
            reloadServerModel()
            root.title = i18n("Advanced Radio Player")
        }
        onStopped: {
            playMusic.stop()
            root.title = i18n("Advanced Radio Player")
        }
        volume: 0.8
    }

    Timer {
        interval: 1000
        repeat: isPlaying() ? true : false
        running: true
        id: im
        onTriggered: {
            if (playMusic.metaData.title != undefined
                    && playMusic.metaData.title.indexOf(' - ') != -1
                    && playMusic.metaData.title.length < 1000) {
                var strings = playMusic.metaData.title.split(' - ')
                var var1 = strings[0].trim(), var2 = strings[1].trim()
                var xmlhttp = new XMLHttpRequest()
                var url = "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=ada39a6834a3be4d641cc1aec7e64d48&artist=" + encodeURIComponent(
                            var1) + "&track=" + encodeURIComponent(
                            var2) + "&autocorrect=1&format=json"
                xmlhttp.onreadystatechange = function () {
                    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                        var myArr = JSON.parse(xmlhttp.responseText)

                        myFunction(myArr)
                    }
                }
                xmlhttp.open("GET", url)
                xmlhttp.send()

                function myFunction(arr) {
                    var art = (arr.track
                               && arr.track.artist) ? (arr.track.artist.name) : var1
                    var tit = (arr.track) ? (arr.track.name) : var2
                    var img
                    root.title = (isPlaying()) ? art : i18n(
                                                     "Advanced Radio Player")
                    root.subtitle = (isPlaying()) ? tit : i18n("Choose station")
                    if (arr.track && arr.track.album
                            && arr.track.album.image[1]['#text']
                            && arr.track.album.image[1]['#text'] != 'undefined'
                            && arr.track.album.image[1]['#text'].startsWith(
                                'http')) {
                        img = arr.track.album.image[1]['#text']
                    } else {
                        img = "../images/unknown.svg"
                    }
                    root.imgurl = (isPlaying()) ? img : "../images/blank.svg"
                }
            } else {
                root.imgurl = (isPlaying(
                                   )) ? "../images/unknown.svg" : "../images/blank.svg"
                root.title = (isPlaying()) ? i18n("Unknown Artist") : i18n(
                                                 "Advanced Radio Player")
                root.subtitle = (isPlaying()) ? i18n("Unknown Song") : i18n(
                                                    "Choose station")

                im.restart()
            }
        }
    }

    function createNotification() {
        var service = notificationSource.serviceForSource("notification")
        var operation = service.operationDescription("createNotification")
        operation.appName = i18n("Advanced Radio Player")
        operation["appIcon"] = plasmoid.configuration.icon
        operation.summary = root.title
        operation["body"] = root.subtitle
        operation["timeout"] = 5000
        service.startOperationCall(operation)
    }

    Plasmoid.compactRepresentation: Item {
        id: comp
        Layout.preferredWidth: plasmoid.configuration.panel ? plasmoid.configuration.panelWidth : ""
        width: plasmoid.configuration.panel ? plasmoid.configuration.panelWidth : ""
        height: parent.height
        clip: true

        PlasmaCore.IconItem {
            id: ima
            anchors.fill: parent
            visible: !plasmoid.configuration.panel
            source: plasmoid.configuration.icon
            width: parent.width
            height: parent.height
            opacity: isPlaying() ? 0.5 : 1
        }

        PlasmaCore.IconItem {
            id: stat
            source: 'media-playback-start'
            visible: isPlaying() && !plasmoid.configuration.panel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height * 0.5
        }

        QQC2.Label {
            id: volumeControl
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: plasmoid.configuration.panel ? Math.round(
                                                     playMusic.volume * 100) + "% " + i18n(
                                                     "Volume") : Math.round(
                                                     playMusic.volume * 100) + "%"
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: units.smallSpacing
            anchors.bottomMargin: units.smallSpacing
            radius: units.smallSpacing
            visible: plasmoid.configuration.panel
            border.width: 0.6
            border.color: PlasmaCore.ColorScope.textColor
            //opacity: 0.5
            id: square
            width: plasmoid.configuration.panelWidth
            height: parent.height
            onWidthChanged: {
                anim.restart()
                volumeControl.visible = false
                stat.opacity = 1
                ima.visible = plasmoid.configuration.panel ? false : true
                nameText2.visible = plasmoid.configuration.panel ? true : false
                im.start()
            }
            color: "transparent"
            PlasmaComponents.Label {
                id: nameText2
                color: textColor
                opacity: 1
                height: parent.height
                text: isPlaying() ? root.title + ' - ' + root.subtitle : i18n(
                                        "Advanced Radio Player")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                onTextChanged: {
                    anim.restart()
                }
            }
            NumberAnimation {
                property: "x"
                id: anim
                target: nameText2
                from: isPlaying() && root.title != i18n(
                          "Advanced Radio Player") ? plasmoid.configuration.panelWidth : plasmoid.configuration.panelWidth + square.width / 2
                to: (isPlaying()) ? -nameText2.width : -nameText2.width / 2
                                    + plasmoid.configuration.panelWidth / 2
                duration: 20 * Math.abs(to - from)
                loops: (isPlaying() && root.title != i18n(
                            "Advanced Radio Player")) ? Animation.Infinite : 1
            }
        }

        Timer {
            id: elapsedTimer
            interval: 3000
            running: false
            repeat: false
            onTriggered: {
                volumeControl.visible = false
                stat.opacity = 1
                ima.visible = plasmoid.configuration.panel ? false : true
                nameText2.visible = plasmoid.configuration.panel ? true : false
                im.start()
            }
        }

        MouseArea {
            id: mouseArea
            width: parent.width
            height: parent.width
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {

            }
            onExited: {
                elapsedTimer.start()
            }
            onClicked: {
                plasmoid.expanded = !plasmoid.expanded
            }
            onWheel: {
                im.stop()
                volumeControl.visible = true
                stat.opacity = 0
                ima.visible = false
                nameText2.visible = false
                if (wheel.angleDelta.y > 0 && playMusic.volume < 1) {
                    playMusic.volume += 0.05
                } else if (wheel.angleDelta.y < 0 && playMusic.volume > 0) {
                    playMusic.volume -= 0.05
                }
                elapsedTimer.start()
            }
        }

        PlasmaCore.ToolTipArea {
            id: toolTip
            width: parent.width
            height: parent.height
            anchors.fill: parent
            mainItem: tool
            interactive: true
        }
    }

    Plasmoid.fullRepresentation: Rectangle {
        Layout.preferredWidth: 200 * units.devicePixelRatio
        Layout.preferredHeight: 300 * units.devicePixelRatio
        clip: true
        color: "transparent"
        anchors.margins: plasmoid.location == PlasmaCore.Types.Floating
                         && root.transback == true ? units.smallSpacing * 2 : 0
        Rectangle {
            id: squaref
            width: 200 * units.devicePixelRatio
            height: plasmoid.configuration.panel ? 0 : 20 * units.devicePixelRatio
            visible: !plasmoid.configuration.panel
            color: "transparent"
            PlasmaComponents.Label {
                id: nameText21
                color: textColor
                height: parent.height
                text: isPlaying() ? root.title + ' - ' + root.subtitle : i18n(
                                        "Advanced Radio Player")
                verticalAlignment: Text.AlignVCenter

                onTextChanged: {
                    anim2.restart()
                }
            }
            NumberAnimation {
                property: "x"
                id: anim2
                target: nameText21
                from: isPlaying() && root.title != i18n(
                          "Advanced Radio Player") ? squaref.width : squaref.width + 150
                to: (isPlaying(
                         )) ? -nameText21.width : -nameText21.width / 2 + squaref.width / 2
                duration: 20 * Math.abs(to - from)
                loops: (isPlaying()) ? Animation.Infinite : 1
            }
            PlasmaCore.ToolTipArea {
                id: toolTip2
                width: parent.width
                height: parent.height
                anchors.fill: parent
                mainItem: tool
                interactive: true
                visible: plasmoid.location == PlasmaCore.Types.Floating
            }
            MouseArea {
                id: mouseArea2
                width: parent.width
                height: parent.width
                anchors.fill: parent
                hoverEnabled: true
                visible: plasmoid.location !== PlasmaCore.Types.Floating
                onEntered: {
                    (isPlaying()) ? anim.pause() : anim.resume()
                }
                onExited: {
                    anim.resume()
                }
                onClicked: {

                }
            }
        }
        ListView {
            id: serversListView
            anchors.fill: parent
            anchors.topMargin: plasmoid.configuration.panel ? 0 : 25
            anchors.bottomMargin: 25
            model: serversModel
            clip: true

            spacing: 1 * units.devicePixelRatio
            delegate: Rectangle {
                height: nameText.paintedHeight + units.smallSpacing
                color: model.status == 1 ? mouseArea3.containsMouse ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.highlightColor : "transparent"
                border.color: mouseArea3.containsMouse ? PlasmaCore.ColorScope.highlightColor : "transparent"
                radius: units.smallSpacing

                width: parent.width

                PlasmaComponents.Label {
                    id: icon
                    color: model.status
                           == 1 ? PlasmaCore.ColorScope.highlightedTextColor : textColor
                    height: parent.height
                    text: model.index + 1
                    width: 16 * units.devicePixelRatio
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.leftMargin: units.smallSpacing
                    anchors.left: parent.left

                    visible: mouseArea3.containsMouse
                             || model.status == 1 ? false : true
                }
                PlasmaCore.IconItem {
                    id: numberPlay
                    width: 16 * units.devicePixelRatio
                    anchors.leftMargin: units.smallSpacing
                    anchors.left: parent.left
                    height: parent.height

                    source: model.status == 1
                            && mouseArea3.containsMouse ? model.status == 1
                                                          && !mouseArea3.containsMouse ? isPlaying() && !mouseArea3.containsMouse ? 'media-playback-start' : 'media-playback-stop' : 'media-playback-stop' : 'media-playback-start'
                    visible: mouseArea3.containsMouse
                             || model.status == 1 ? true : false
                    opacity: model.status === 1
                             && playMusic.bufferProgress < 1 ? 0.3 : 1
                    colorGroup: model.status == 1 ? PlasmaCore.Theme.ComplementaryColorGroup : PlasmaCore.Theme.NormalColorGroup
                }
                BusyIndicator {
                    width: icon.width * 1
                    height: icon.height * 1
                    anchors.verticalCenter: icon.verticalCenter
                    anchors.horizontalCenter: icon.horizontalCenter
                    running: model.status === 1 && playMusic.bufferProgress < 1
                    visible: model.status === 1 && playMusic.bufferProgress < 1
                }
                PlasmaComponents.Label {
                    id: nameText

                    color: model.status
                           == 1 ? PlasmaCore.ColorScope.highlightedTextColor : textColor
                    anchors.left: icon.right
                    anchors.leftMargin: units.smallSpacing
                    height: parent.height
                    text: model.name.length === 0 ? model.hostname : model.name
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.bold: model.status === 1 ? true : false
                }

                MouseArea {
                    id: mouseArea3
                    anchors.top: icon.top
                    anchors.bottom: icon.bottom
                    anchors.left: icon.left
                    width: serversListView.width
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {

                    }

                    onClicked: {
                        serversListView.currentIndex = model.index
                        refreshServer(model.index)
                    }
                }
            }
        }
        Rectangle {
            id: square2
            width: 200
            height: 30
            anchors.top: serversListView.bottom
            color: "transparent"
            z: 10
            PlasmaComponents.Label {
                id: nameText3
                color: textColor
                font.pixelSize: 10
                height: parent.height
                width: parent.width
                text: isPlaying(
                          ) ? i18n("Bitrate:") + ' ' + Math.round(
                                  playMusic.metaData.audioBitRate / 1000) + 'Kb/s, ' + i18n(
                                  "Genre:") + ' '
                              + playMusic.metaData.genre : playMusic.bufferProgress < 1
                              && play.running == true ? i18n("Buffering") + ' ' + Math.round(playMusic.bufferProgress * 100) + "%" : i18n(
                                                            "Choose station and enjoy...")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        PlasmaComponents.Button {
            anchors.centerIn: parent
            text: i18n("Add stations")
            visible: serversModel.count == 0
            onClicked: plasmoid.action("configure").trigger()
        }
    }
    function reloadServerModel() {
        serversModel.clear()
        playMusic.stop()
        var servers = JSON.parse(plasmoid.configuration.servers)
        for (var i = 0; i < servers.length; i++) {
            if (servers[i].active) {
                serversModel.append(servers[i])
            }
        }
    }
    function refreshServer(index) {
        if (isPlaying() && playMusic.source == serversModel.get(
                    index).hostname) {
            playMusic.stop()
            playMusic.source = ''
            serversModel.setProperty(index, "status", 0)
        } else {
            playMusic.stop()
            playMusic.source = ''
            for (var i = 0; i < serversModel.count; i++) {
                serversModel.setProperty(i, "status", 0)
            }
            playMusic.source = serversModel.get(index).hostname
            serversModel.setProperty(index, "status", 1)
            play.start()
        }
    }
    Timer {
        id: play
        interval: 200
        repeat: false
        running: false
        onTriggered: {
            if (playMusic.bufferProgress == 1) {
                playMusic.play()
                play.stop()
            } else {
                play.restart()
            }
        }
    }

    function isPlaying() {
        return playMusic.playbackState == MediaPlayer.PlayingState
    }
}
