// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qupil

Page {
    id: root
    signal openPupils()
    signal openLesson(int recordId)

    property var stats: App.dashboardStats()
    property var today: App.todayLessons()

    function reload() {
        stats = App.dashboardStats()
        today = App.todayLessons()
    }

    Connections { target: App; function onDataChanged() { root.reload() } }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: root.width
            spacing: 16
            anchors.margins: 16

            Label {
                text: qsTr("Today")
                font.pixelSize: 30
                font.bold: true
                Layout.leftMargin: 16
                Layout.topMargin: 18
            }

            GridLayout {
                columns: root.width > 760 ? 5 : (root.width > 480 ? 3 : 2)
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                Repeater {
                    model: [
                        [qsTr("Pupils"), root.stats.pupils || 0],
                        [qsTr("Lessons"), root.stats.lessons || 0],
                        [qsTr("Reminders"), root.stats.reminders || 0],
                        [qsTr("Loaned scores"), root.stats.loanedMusic || 0],
                        [qsTr("Events"), root.stats.recitals || 0]
                    ]
                    delegate: Pane {
                        required property int index

                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
                        ColumnLayout {
                            anchors.fill: parent
                            Label { text: modelData[1]; font.pixelSize: 28; font.bold: true }
                            Label { text: modelData[0]; opacity: 0.7; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (index === 0) root.openPupils()
                        }
                    }
                }
            }

            Label {
                text: qsTr("Today's lessons")
                font.pixelSize: 22
                font.bold: true
                Layout.leftMargin: 16
                Layout.topMargin: 8
            }

            Label {
                visible: root.today.length === 0
                text: qsTr("No regular lessons are scheduled for today.")
                opacity: 0.65
                Layout.leftMargin: 16
            }

            Repeater {
                model: root.today
                delegate: ItemDelegate {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    contentItem: Column {
                        spacing: 3
                        Label { text: (modelData.start || "") + "–" + (modelData.stop || "") + "  " + (modelData.name || ""); font.bold: true }
                        Label { text: [modelData.pupils || "", modelData.location || ""].filter(x => x.length).join(" · "); opacity: 0.7 }
                    }
                    onClicked: root.openLesson(modelData.id)
                }
            }
            Item { Layout.preferredHeight: 16 }
        }
    }
}
