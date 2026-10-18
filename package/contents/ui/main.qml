import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects as QtEffects
import QtQuick.Layouts 2.15
import "dateBlocks.js" as DateBlocks
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

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
    property string dateFontFamily: plasmoid.configuration.date_font_family == "Default" ? font_livvic.name : plasmoid.configuration.date_font_family
    // 日期行积木：优先用新配置，其次从旧 date_format 迁移，最后回退默认
    property var dateBlocks: DateBlocks.blocksForStored(plasmoid.configuration.date_blocks, plasmoid.configuration.date_format)

    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    FontLoader {
        id: font_livvic

        source: "../fonts/Livvic.ttf"
    }

    compactRepresentation: Item {
        Layout.minimumWidth: compactText.implicitWidth
        Layout.minimumHeight: compactText.implicitHeight

        PlasmaComponents.Label {
            id: compactText

            text: i18n("Panels are too small for me!")
        }

    }

    fullRepresentation: Item {
        id: fullRoot

        // 保留阴影空间
        property int frameExtra: root.frameShadowEnabled ? root.frameShadowRadius * 2 : 0
        property int textExtra: root.textShadowEnabled ? root.textShadowRadius * 2 : 0
        property int shadowExtra: Math.max(frameExtra, textExtra)

        // 时间+日期渲染入口。三处调用：整分 tick、配置页改了日期积木、首屏。
        function updateDateTime(curDate) {
            if (!curDate)
                curDate = new Date();

            timeLabel.text = Qt.formatTime(curDate, "hh mm");
            dateLabel.text = DateBlocks.render(root.dateBlocks, curDate);
        }

        Layout.minimumWidth: column.implicitWidth + shadowExtra
        Layout.minimumHeight: column.implicitHeight + shadowExtra
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        Component.onCompleted: {
            var d = dataSource.data["Local"];
            updateDateTime(d ? d["DateTime"] : new Date());
        }

        // 配置页改了日期积木后立刻重渲染，不等整分 tick。
        // 放 Connections 里是因为 onDateBlocksChanged 是 root 的信号，fullRoot 内不能直写。
        Connections {
            function onDateBlocksChanged() {
                var d = dataSource.data["Local"];
                fullRoot.updateDateTime(d ? d["DateTime"] : new Date());
            }

            target: root
        }

        Plasma5Support.DataSource {
            id: dataSource

            engine: "time"
            connectedSources: ["Local"]
            interval: 60000
            intervalAlignment: Plasma5Support.Types.AlignToMinute
            onDataChanged: {
                updateDateTime(dataSource.data["Local"]["DateTime"]);
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
            color: Qt.rgba(0, 0, 0, root.frameShadowOpacity / 100)
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

                    PlasmaComponents.Label {
                        id: timeLabel

                        color: root.effectiveFontColor
                        font.pixelSize: root.timeFontSize
                        font.family: root.timeFontFamily
                        font.letterSpacing: root.timeLetterSpacing
                        font.wordSpacing: root.timeWordSpacing
                    }

                    layer.effect: QtEffects.MultiEffect {
                        shadowEnabled: root.textShadowEnabled
                        shadowBlur: root.textShadowRadius / 12
                        shadowColor: Qt.rgba(0, 0, 0, root.textShadowOpacity / 100)
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 1
                    }

                }

            }

            PlasmaComponents.Label {
                id: dateLabel

                anchors.horizontalCenter: parent.horizontalCenter
                color: root.effectiveFontColor
                font.pixelSize: root.dateFontSize
                font.letterSpacing: root.dateLetterSpacing
                font.family: root.dateFontFamily
                // 日期文本同样支持独立文字阴影
                layer.enabled: root.textShadowEnabled && root.textShadowOpacity > 0 && root.textShadowRadius > 0

                layer.effect: QtEffects.MultiEffect {
                    shadowEnabled: root.textShadowEnabled
                    shadowBlur: root.textShadowRadius / 12
                    shadowColor: Qt.rgba(0, 0, 0, root.textShadowOpacity / 100)
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 1
                }

            }

        }

    }

}
