import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    height: mainRow.implicitHeight
    property string fontFamily;

    function getFontsModel() {
        var arr = Qt.fontFamilies()
        arr.splice(0, 0, "Default")
        return arr
    }

    Timer {
        id: timer
        interval: 10
        running: false
        onTriggered: root.fontFamily=combo.currentText
    }
    // ComboBox
    RowLayout {
        id: mainRow
        Label {
            text: i18n("Font")
        }
        ComboBox {
            id: combo
            model: getFontsModel()
            onCurrentIndexChanged: timer.running=true
        }
    } 
}
