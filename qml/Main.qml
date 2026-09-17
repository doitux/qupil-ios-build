// SPDX-License-Identifier: GPL-2.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qupil
import "components"

ApplicationWindow {
id: root
    width: 1180
    height: 760
    minimumWidth: 360
    minimumHeight: 560
    visible: true
    title: qsTr("Qupil")

    property bool compact: width < 820
    property string pageTitle: qsTr("Overview")
    property string lastRuntimeMinute: ""
    property var notificationQueue: []
    property var activeNotification: ({})
    property string lessonEndMessage: ""

    function enqueueNotifications(items) {
        if (!items || items.length === 0)
            return
        let queue = notificationQueue.slice()
        for (let i = 0; i < items.length; ++i)
            queue.push(items[i])
        notificationQueue = queue
        showNextNotification()
    }

    function showNextNotification() {
        if (runtimeReminder.visible || notificationQueue.length === 0)
            return
        const queue = notificationQueue.slice()
        activeNotification = queue.shift()
        notificationQueue = queue
        if (activeNotification.sound)
            Metronome.playNotificationSound()
        runtimeReminder.open()
    }

    function checkRuntimeNotifications(includeCurrentLesson) {
        const minuteKey = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm")
        if (!includeCurrentLesson && minuteKey === lastRuntimeMinute)
            return
        lastRuntimeMinute = minuteKey
        enqueueNotifications(App.lessonReminders(includeCurrentLesson))
        const warnings = App.lessonEndWarnings()
        if (warnings && warnings.length > 0) {
            let messages = []
            for (let i = 0; i < warnings.length; ++i)
                messages.push(warnings[i].description)
            lessonEndMessage = messages.join("\n")
            Metronome.playLessonEndSound()
            lessonEndPopup.open()
        }
    }

    Component.onCompleted: {
        enqueueNotifications(App.startupReminders())
        checkRuntimeNotifications(true)
    }

    function showDashboard() { pageTitle = qsTr("Overview"); stack.replace(dashboardComponent); drawer.close() }
    function showSchedule() { pageTitle = qsTr("Schedule"); stack.replace(scheduleComponent); drawer.close() }
    function showPupils() { pageTitle = qsTr("Pupils"); stack.replace(pupilsComponent); drawer.close() }
    function showPupil(id) { pageTitle = id < 0 ? qsTr("New pupil") : qsTr("Pupil"); stack.replace(pupilDetailComponent, { pupilId: id }); drawer.close() }
    function showLessons() { pageTitle = qsTr("Lessons"); stack.replace(lessonsComponent); drawer.close() }
    function showLesson(id) { pageTitle = id < 0 ? qsTr("New lesson") : qsTr("Lesson"); stack.replace(lessonDetailComponent, { lessonId: id }); drawer.close() }
    function showReminders() { pageTitle = qsTr("Reminders"); stack.replace(remindersComponent); drawer.close() }
    function showLibrary() { pageTitle = qsTr("Music library"); stack.replace(libraryComponent); drawer.close() }
    function showRecitals() { pageTitle = qsTr("Events"); stack.replace(recitalsComponent); drawer.close() }
    function showRecital(id) { pageTitle = id < 0 ? qsTr("New event") : qsTr("Event"); stack.replace(recitalDetailComponent, { recitalId: id }); drawer.close() }
    function showArchive() { pageTitle = qsTr("Pupil archive"); stack.replace(archiveComponent); drawer.close() }
    function showMetronome() { pageTitle = qsTr("Metronome"); stack.replace(metronomeComponent); drawer.close() }
    function showSettings() { pageTitle = qsTr("Settings"); stack.replace(settingsComponent); drawer.close() }
    function showReports() { pageTitle = qsTr("Checks & reports"); stack.replace(reportsComponent); drawer.close() }
    function showCsvImport() { pageTitle = qsTr("CSV import"); stack.replace(csvImportComponent); drawer.close() }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                visible: root.compact
                text: "☰"
                font.pixelSize: 22
                onClicked: drawer.open()
            }
            Label {
                text: root.pageTitle
                font.pixelSize: 20
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            ToolButton {
                text: "↻"
                Accessible.name: qsTr("Refresh")
                onClicked: App.refreshAll()
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(root.width * 0.82, 300)
        height: root.height
        edge: Qt.LeftEdge
        modal: true

        NavigationPanel { anchors.fill: parent }
    }

    component NavigationPanel: Pane {
        padding: 8
        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Label {
                text: qsTr("Qupil")
                font.pixelSize: 28
                font.bold: true
                Layout.leftMargin: 12
                Layout.topMargin: 8
                Layout.bottomMargin: 8
            }

            Repeater {
                model: [
                    [qsTr("Overview"), "⌂"],
                    [qsTr("Schedule"), "▤"],
                    [qsTr("Pupils"), "♙"],
                    [qsTr("Lessons"), "◷"],
                    [qsTr("Events"), "☆"],
                    [qsTr("Music library"), "♫"],
                    [qsTr("Reminders"), "!"],
                    [qsTr("Pupil archive"), "▣"],
                    [qsTr("Metronome"), "♪"],
                    [qsTr("Checks & reports"), "✓"],
                    [qsTr("Settings"), "⚙"]
                ]
                delegate: ItemDelegate {
                    required property int index

                    required property var modelData
                    text: modelData[1] + "   " + modelData[0]
                    Layout.fillWidth: true
                    onClicked: {
                        switch (index) {
                        case 0: root.showDashboard(); break
                        case 1: root.showSchedule(); break
                        case 2: root.showPupils(); break
                        case 3: root.showLessons(); break
                        case 4: root.showRecitals(); break
                        case 5: root.showLibrary(); break
                        case 6: root.showReminders(); break
                        case 7: root.showArchive(); break
                        case 8: root.showMetronome(); break
                        case 9: root.showReports(); break
                        case 10: root.showSettings(); break
                        }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Label {
                text: qsTr("Database: %1").arg(App.databasePath)
                wrapMode: Text.WrapAnywhere
                opacity: 0.55
                font.pixelSize: 11
                Layout.fillWidth: true
                Layout.margins: 12
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationPanel {
            visible: !root.compact
            Layout.preferredWidth: 230
            Layout.fillHeight: true
        }

        Rectangle {
            visible: !root.compact
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: root.palette.mid
        }

        StackView {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            initialItem: dashboardComponent
        }
    }

    Rectangle {
        visible: App.lastError.length > 0
        z: 100
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: errorRow.implicitHeight + 18
        color: root.palette.window
        border.color: root.palette.mid

        RowLayout {
            id: errorRow
            anchors.fill: parent
            anchors.margins: 9
            Label {
                text: App.lastError
                color: root.palette.text
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            Button { text: qsTr("Dismiss"); onClicked: App.clearLastError() }
        }
    }


    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.checkRuntimeNotifications(false)
    }

    Dialog {
        id: runtimeReminder
        anchors.centerIn: parent
        width: Math.min(520, root.width - 32)
        modal: false
        title: root.activeNotification.pupilName
               ? qsTr("Reminder for %1").arg(root.activeNotification.pupilName)
               : qsTr("Reminder")
        standardButtons: Dialog.Ok
        onClosed: Qt.callLater(root.showNextNotification)
        ColumnLayout {
            width: parent.width
            Label {
                text: root.activeNotification.description || ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                font.pixelSize: 17
            }
            Button {
                visible: Number(root.activeNotification.mode) === 2
                text: qsTr("Done – remove reminder")
                onClicked: {
                    App.deleteReminder(Number(root.activeNotification.id))
                    runtimeReminder.close()
                }
            }
        }
    }

    Popup {
        id: lessonEndPopup
        anchors.centerIn: parent
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 18
        ColumnLayout {
            Label { text: qsTr("Lesson ending soon"); font.bold: true; font.pixelSize: 18 }
            Label { text: root.lessonEndMessage; wrapMode: Text.WordWrap; Layout.maximumWidth: 440 }
            Button { text: qsTr("OK"); onClicked: lessonEndPopup.close() }
        }
    }

    Component { id: dashboardComponent; DashboardPage { onOpenPupils: root.showPupils(); onOpenLesson: id => root.showLesson(id) } }
    Component { id: scheduleComponent; SchedulePage { onEditLesson: id => root.showLesson(id) } }
    Component { id: pupilsComponent; PupilsPage { onEditPupil: id => root.showPupil(id) } }
    Component { id: pupilDetailComponent; PupilDetailPage { onDone: root.showPupils() } }
    Component { id: lessonsComponent; LessonsPage { onEditLesson: id => root.showLesson(id) } }
    Component { id: lessonDetailComponent; LessonDetailPage { onDone: root.showLessons() } }
    Component { id: remindersComponent; RemindersPage {} }
    Component { id: libraryComponent; LibraryPage {} }
    Component { id: recitalsComponent; RecitalsPage { onEditRecital: id => root.showRecital(id) } }
    Component { id: recitalDetailComponent; RecitalDetailPage { onDone: root.showRecitals() } }
    Component { id: archiveComponent; ArchivePage {} }
    Component { id: metronomeComponent; MetronomePage {} }
    Component { id: settingsComponent; SettingsPage { onOpenCsvImport: root.showCsvImport() } }
    Component { id: reportsComponent; ReportsPage { onEditPupil: id => root.showPupil(id) } }
    Component { id: csvImportComponent; CsvImportPage { onDone: root.showSettings() } }
}
