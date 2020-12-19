import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import ".."

Item {
    id: configGeneral
    Layout.fillWidth: true
    property string cfg_servers: plasmoid.configuration.servers
    property string cfg_version: plasmoid.configuration.version
    property string metadataFilepath: plasmoid.file("", "../metadata.desktop")
    property int dialogMode: -1

    ServersModel {
        id: serversModel
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: executable
        onExited: {
            cfg_version = stdout.replace('\n', ' ').trim()
        }
    }

    Component.onCompleted: {
        var cmd = 'kreadconfig5 --file "' + metadataFilepath
                + '" --group "Desktop Entry" --key "X-KDE-PluginInfo-Version"'
        executable.exec(cmd)
        serversModel.clear()
        var servers = JSON.parse(cfg_servers)
        for (var i = 0; i < servers.length; i++) {
            serversModel.append(servers[i])
        }
    }

    RowLayout {

        anchors.fill: parent
        Layout.alignment: Qt.AlignTop | Qt.AlignRight

        TableView {
            id: serversTable
            model: serversModel
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            TableViewColumn {
                title: "👁"
                role: "active"
                horizontalAlignment: Text.AlignHCenter
                width: 30
                delegate: CheckBox {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    checked: model.active
                    onVisibleChanged: if (visible)
                                          checked = styleData.value
                    onClicked: {
                        model.active = checked
                        cfg_servers = JSON.stringify(getServersArray())
                    }
                }
            }

            TableViewColumn {
                role: "name"
                title: i18n("Name")
                width: serversTable.width - 35
            }

            onDoubleClicked: {
                editServer()
            }

            onClicked: {
                edit.enabled = true
                remove.enabled = true
                moveUp.enabled = true
                moveDown.enabled = true
            }
        }
        ColumnLayout {
            id: buttonsColumn
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true

            Button {
                text: i18n("Add")
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                iconName: "list-add"

                onClicked: {
                    addServer()
                }
            }

            Button {
                id: edit
                text: i18n("Edit")
                iconName: "edit-entry"
                Layout.fillWidth: true
                enabled: false
                onClicked: {
                    editServer()
                }
            }

            Button {
                id: remove
                text: i18n("Remove")
                iconName: "list-remove"
                Layout.fillWidth: true
                enabled: false
                onClicked: {
                    if (serversTable.currentRow == -1)
                        return

                    serversTable.model.remove(serversTable.currentRow)

                    cfg_servers = JSON.stringify(getServersArray())
                }
            }

            Button {
                id: moveUp
                text: i18n("Move up")
                iconName: "go-up"
                enabled: false
                Layout.fillWidth: true
                onClicked: {
                    if (serversTable.currentRow == -1
                            || serversTable.currentRow == 0) {
                        this.enabled == false
                        return
                    }
                    serversTable.model.move(serversTable.currentRow,
                                            serversTable.currentRow - 1, 1)
                    serversTable.selection.clear()
                    serversTable.selection.select(serversTable.currentRow - 1)
                    cfg_servers = JSON.stringify(getServersArray())
                }
            }

            Button {
                id: moveDown
                text: i18n("Move down")
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                iconName: "go-down"
                Layout.fillWidth: true
                enabled: false
                onClicked: {
                    if (serversTable.currentRow == -1
                            || serversTable.currentRow == serversTable.model.count - 1) {
                        this.enabled == false
                        return
                    }
                    serversTable.model.move(serversTable.currentRow,
                                            serversTable.currentRow + 1, 1)
                    serversTable.selection.clear()
                    serversTable.selection.select(serversTable.currentRow + 1)
                    cfg_servers = JSON.stringify(getServersArray())
                }
            }
            Label {
                text: i18n("Version: %1", cfg_version)
                verticalAlignment: Text.AlignBottom
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            }
        }
    }

    Dialog {
        id: serverDialog
        visible: false
        title: i18n("Station")
        standardButtons: StandardButton.Cancel | StandardButton.Save

        onAccepted: {
            var itemObject = {
                "name": serverName.text,
                "hostname": serverHostname.text,
                "active": serverActive.checked
            }

            if (dialogMode == -1) {
                serversModel.append(itemObject)
            } else {
                serversModel.set(dialogMode, itemObject)
            }

            cfg_servers = JSON.stringify(getServersArray())
        }

        ColumnLayout {
            GridLayout {
                columns: 2

                Label {
                    text: i18n("Name:")
                }

                TextField {
                    id: serverName
                    Layout.minimumWidth: theme.mSize(
                                             theme.defaultFont).width * 40
                }

                Label {
                    text: i18n("Station URL:")
                }

                TextField {
                    id: serverHostname
                    Layout.minimumWidth: theme.mSize(
                                             theme.defaultFont).width * 40
                }

                Label {
                    text: ""
                }

                CheckBox {
                    id: serverActive
                    text: i18n("Active")
                }
            }
        }
    }

    function addServer() {
        dialogMode = -1

        serverName.text = ""
        serverHostname.text = ""
        serverActive.checked = true
        serverDialog.visible = true
        serverName.focus = true
    }

    function editServer() {
        dialogMode = serversTable.currentRow

        serverName.text = serversModel.get(dialogMode).name
        serverHostname.text = serversModel.get(dialogMode).hostname
        serverActive.checked = serversModel.get(dialogMode).active
        serverDialog.visible = true
        serverName.focus = true
    }

    function getServersArray() {
        var serversArray = []

        for (var i = 0; i < serversModel.count; i++) {
            serversArray.push(serversModel.get(i))
        }

        return serversArray
    }
}
