import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Font
    FontLoader {
        id: font_livvic
        source: "../fonts/Livvic.ttf"
    }

    // PROPERTIES 
    // global
    property bool enableShadows: plasmoid.configuration.enable_shadows
    property int verticalSpacing: 5
    property string fontColor: plasmoid.configuration.font_color

    // frame 
    property int frameBorderWidth: plasmoid.configuration.frame_border_width
    property int framePadding: plasmoid.configuration.frame_padding

    // time 
    property int timeFontSize: plasmoid.configuration.time_font_size
    property int timeLetterSpacing: plasmoid.configuration.time_letter_spacing
    property int timeWordSpacing: plasmoid.configuration.time_word_spacing
    property string timeFontFamily: plasmoid.configuration.time_font_family == "Default" ? font_livvic.name : plasmoid.configuration.time_font_family

    // date
    property int dateFontSize: plasmoid.configuration.date_font_size
    property int dateLetterSpacing: plasmoid.configuration.date_letter_spacing
    property int dateSpacing: plasmoid.configuration.date_spacing
    property string dateFontFamily: plasmoid.configuration.date_font_family == "Default" ? font_livvic.name : plasmoid.configuration.date_font_family


    // making the background configurable
    Plasmoid.backgroundHints: (enableShadows ? PlasmaCore.Types.ShadowBackground : PlasmaCore.Types.NoBackground) | PlasmaCore.Types.ConfigurableBackground

    // layout
    compactRepresentation: Item {
        Layout.minimumWidth: compactText.implicitWidth 
        Layout.minimumHeight: compactText.implicitHeight

        PlasmaComponents.Label {
            id: compactText
            text: i18n("Panels are too small for me!")
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: column.implicitWidth
        Layout.minimumHeight: column.implicitHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        Plasma5Support.DataSource {
            id: dataSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 60000
            intervalAlignment: Plasma5Support.Types.AlignToMinute
            onDataChanged: {
                var curDate = dataSource.data["Local"]["DateTime"]
                timeLabel.text = Qt.formatTime(curDate, "hh mm")
                dayLabel.text = Qt.formatDate(curDate, "dddd").toUpperCase()
                dateLabel.text = Qt.formatDate(curDate, "dd MMM").toUpperCase()
                console.log(plasmoid.location)
            }
        }
        
        // Main
        Column {
            id: column
            spacing: root.verticalSpacing

            Rectangle {
                id: rectangle 
                color: "transparent"
                border.color: root.fontColor
                border.width: root.frameBorderWidth
                width: timeLabel.implicitWidth + root.framePadding
                height: root.timeFontSize + root.framePadding
            
                PlasmaComponents.Label {
                    id: timeLabel 
                    anchors.centerIn: parent

                    // font settings
                    color: root.fontColor
                    font.pixelSize: root.timeFontSize
                    font.family: root.timeFontFamily
                    font.letterSpacing: root.timeLetterSpacing
                    font.wordSpacing: root.timeWordSpacing
                }
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter 
                spacing: root.dateSpacing

                PlasmaComponents.Label {
                    id: dayLabel

                    // font settings
                    color: root.fontColor
                    font.pixelSize: root.dateFontSize
                    font.letterSpacing: root.dateLetterSpacing
                    font.family: root.dateFontFamily
                }
                PlasmaComponents.Label {
                    id: dateLabel

                    // font settings
                    color: root.fontColor
                    font.pixelSize: root.dateFontSize
                    font.letterSpacing: root.dateLetterSpacing
                    font.family: root.dateFontFamily
                }
            } 
        }
    }
}
