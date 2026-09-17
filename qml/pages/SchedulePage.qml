// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qupil

Page {
    id: root
    signal editLesson(int recordId)
    property var rows: []

    function reload() { rows = App.scheduleForDay(days.currentIndex) }
    Component.onCompleted: { days.currentIndex = Math.max(0, Math.min(6, new Date().getDay() === 0 ? 6 : new Date().getDay() - 1)); reload() }
    Connections { target: App; function onDataChanged() { root.reload() } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: days.implicitHeight + 8
            contentHeight: days.implicitHeight
            contentWidth: days.implicitWidth
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            TabBar {
                id: days
                onCurrentIndexChanged: root.reload()
                Repeater {
                    model: [qsTr("Mon"), qsTr("Tue"), qsTr("Wed"), qsTr("Thu"), qsTr("Fri"), qsTr("Sat"), qsTr("Sun")]
                    TabButton { required property var modelData; text: modelData }
                }
            }
        }

        ListView {
            id: schedule
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.rows
            spacing: 8
            clip: true

            delegate: ItemDelegate {
                required property var modelData
                width: schedule.width
                onClicked: root.editLesson(modelData.id)
                contentItem: RowLayout {
                    ColumnLayout {
                        Layout.preferredWidth: 90
                        Label { text: modelData.start || "—"; font.pixelSize: 20; font.bold: true }
                        Label { text: modelData.stop || ""; opacity: 0.6 }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Label { text: modelData.name; font.bold: true; font.pixelSize: 17; Layout.fillWidth: true; elide: Text.ElideRight }
                        Label { text: modelData.pupils || qsTr("No pupils"); Layout.fillWidth: true; elide: Text.ElideRight }
                        Label { text: [modelData.typeName, modelData.location].filter(x => x && x.length).join(" · "); opacity: 0.6; Layout.fillWidth: true; elide: Text.ElideRight }
                    }
                    Label { text: "›"; font.pixelSize: 28; opacity: 0.5 }
                }
            }

            EmptyState { anchors.centerIn: parent; visible: schedule.count === 0; title: qsTr("No lessons on this day") }
        }
    }
}
