import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Effects as QtEffects
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    FontLoader { id: font_livvic; source: "../fonts/Livvic.ttf" }

    // global
    property bool followSystemColor: plasmoid.configuration.follow_system_color
    property color effectiveFontColor: followSystemColor ? Kirigami.Theme.textColor : plasmoid.configuration.font_color
    property int verticalSpacing: 5

    // 时间数字垂直居中的视觉修正量：数字没有下伸部（descender），而 Text 按
    // ascent+descent 整体高度居中，基线下那段 descent 是空的，字看着会偏下。
    // 截图实测 150px 字号偏下约 10px（≈字号的 6.7%），故按字号的 6.7% 上移补偿。
    property real descentNudge: root.timeFontSize * 0.067

    // frame
    property bool frameShadowEnabled: plasmoid.configuration.enable_shadows
    property int frameShadowRadius: plasmoid.configuration.shadow_radius
    property int frameShadowOpacity: plasmoid.configuration.shadow_opacity
    property int frameBorderWidth: plasmoid.configuration.frame_border_width
    property int framePadding: plasmoid.configuration.frame_padding

    // text shadow
    property bool textShadowEnabled: plasmoid.configuration.text_shadow_enabled
    property int textShadowRadius: plasmoid.configuration.text_shadow_radius
    property int textShadowOpacity: plasmoid.configuration.text_shadow_opacity

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
    property string dateFormat: plasmoid.configuration.date_format || "MM/dd dddd"

    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    compactRepresentation: Item {
        Layout.minimumWidth: compactText.implicitWidth
        Layout.minimumHeight: compactText.implicitHeight
        PlasmaComponents.Label { id: compactText; text: i18n("Panels are too small for me!") }
    }

    fullRepresentation: Item {
        id: fullRoot
        // 保留阴影空间
        property int frameExtra: root.frameShadowEnabled ? root.frameShadowRadius * 2 : 0
        property int textExtra: root.textShadowEnabled ? root.textShadowRadius * 2 : 0
        property int shadowExtra: Math.max(frameExtra, textExtra)
        Layout.minimumWidth: column.implicitWidth + shadowExtra
        Layout.minimumHeight: column.implicitHeight + shadowExtra
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
                // 日期按可配置格式显示，支持 MM/dd dddd 与 MMM dd dddd（含英文月份）
                try {
                    var fmt = root.dateFormat
                    var txt
                    if (fmt.indexOf("MMM") !== -1) {
                        // 英文月份缩写/全称，中文星期需单独处理
                        var enShort = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                        var enLong  = ["January","February","March","April","May","June","July","August","September","October","November","December"]
                        var m = curDate.getMonth() // 0-11
                        // 先替换 MMMM 再替换 MMM，避免重叠
                        var fmtEn = fmt.replace(/MMMM/g, enLong[m]).replace(/MMM/g, enShort[m])
                        txt = Qt.formatDate(curDate, fmtEn)
                    } else {
                        txt = Qt.formatDate(curDate, fmt)
                    }
                    dateLabel.text = txt.toUpperCase()
                    dayLabel.text = ""
                    dayLabel.visible = false
                } catch(e) {
                    dayLabel.text = Qt.formatDate(curDate, "dddd").toUpperCase()
                    dateLabel.text = Qt.formatDate(curDate, "dd MMM").toUpperCase()
                }
            }
        }

        // 边框/线的阴影（跟随边框矩形，需手动同步位置）
        QtEffects.RectangularShadow {
            id: frameShadow
            x: column.x
            y: column.y
            width: rectangle.width
            height: rectangle.height
            visible: root.frameShadowEnabled && root.frameShadowOpacity > 0 && root.frameShadowRadius > 0
            blur: root.frameShadowRadius
            color: Qt.rgba(0, 0, 0, root.frameShadowOpacity / 100.0)
            offset: Qt.vector2d(0, 0)
            spread: 0
            radius: 0
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: root.verticalSpacing

            Rectangle {
                id: rectangle
                color: "transparent"
                border.color: root.effectiveFontColor
                border.width: root.frameBorderWidth
                width: timeLabelWrap.implicitWidth + root.framePadding
                height: root.timeFontSize + root.framePadding

                Item {
                    id: timeLabelWrap
                    anchors.centerIn: parent
                    // 数字没有下伸部，而 Text 是按 ascent+descent 整体高度居中的，
                    // 基线下那段 descent 是空的，会让字看起来偏下。上移半个 descent 抵消它。
                    anchors.verticalCenterOffset: -root.descentNudge
                    implicitWidth: timeLabel.implicitWidth
                    implicitHeight: timeLabel.implicitHeight
                    // 文字阴影通过 layer 效果实现，独立于边框阴影
                    layer.enabled: root.textShadowEnabled && root.textShadowOpacity > 0 && root.textShadowRadius > 0
                    layer.effect: QtEffects.MultiEffect {
                        shadowEnabled: root.textShadowEnabled
                        shadowBlur: root.textShadowRadius / 12.0
                        shadowColor: Qt.rgba(0,0,0, root.textShadowOpacity/100.0)
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 1
                    }
                    PlasmaComponents.Label {
                        id: timeLabel
                        color: root.effectiveFontColor
                        font.pixelSize: root.timeFontSize
                        font.family: root.timeFontFamily
                        font.letterSpacing: root.timeLetterSpacing
                        font.wordSpacing: root.timeWordSpacing
                    }
                }
            }

            Row {
                id: dateRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.dateSpacing
                // 日期文本同样支持独立文字阴影
                layer.enabled: root.textShadowEnabled && root.textShadowOpacity > 0 && root.textShadowRadius > 0
                layer.effect: QtEffects.MultiEffect {
                    shadowEnabled: root.textShadowEnabled
                    shadowBlur: root.textShadowRadius / 12.0
                    shadowColor: Qt.rgba(0,0,0, root.textShadowOpacity/100.0)
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 1
                }
                PlasmaComponents.Label {
                    id: dayLabel
                    visible: false
                    color: root.effectiveFontColor
                    font.pixelSize: root.dateFontSize
                    font.letterSpacing: root.dateLetterSpacing
                    font.family: root.dateFontFamily
                }
                PlasmaComponents.Label {
                    id: dateLabel
                    color: root.effectiveFontColor
                    font.pixelSize: root.dateFontSize
                    font.letterSpacing: root.dateLetterSpacing
                    font.family: root.dateFontFamily
                }
            }
        }
    }
}
