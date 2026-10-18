import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "dateBlocks.js" as DateBlocks
import org.kde.kirigami as Kirigami

Item {
    id: root

    // ---- 配置绑定（与 main.xml 一一对应） ----
    // 边框阴影开关 + 边框
    property alias cfg_enable_shadows: enableShadows.checked
    property alias cfg_frame_padding: framePadding.value
    property alias cfg_frame_border_width: frameBorderWidth.value
    // 边框阴影
    property alias cfg_shadow_radius: frameShadowRadius.value
    property alias cfg_shadow_opacity: frameShadowOpacity.value
    // 文字阴影
    property alias cfg_text_shadow_enabled: textShadowEnabled.checked
    property alias cfg_text_shadow_radius: textShadowRadius.value
    property alias cfg_text_shadow_opacity: textShadowOpacity.value
    // 时间
    property alias cfg_time_font_family: timeFontFamily.fontFamily
    property alias cfg_time_letter_spacing: timeLetterSpacing.value
    property alias cfg_time_word_spacing: timeWordSpacing.value
    property alias cfg_time_font_size: timeFontSize.value
    // 日期
    property alias cfg_date_font_family: dateFontFamily.fontFamily
    property alias cfg_date_letter_spacing: dateLetterSpacing.value
    property alias cfg_date_font_size: dateFontSize.value
    // 旧版日期格式串：只读，仅用于把老配置迁移成积木，不再在设置页暴露
    property string cfg_date_format: "MM/dd dddd"
    // 日期行积木（JSON 数组）；为空时按旧的 cfg_date_format 迁移，再回退默认
    property string cfg_date_blocks: ""
    // 颜色
    property alias cfg_follow_system_color: followSystemColor.checked
    property alias cfg_font_color: fontColorProxy.chosenColor

    // 把配置里的积木同步给编辑器。只在配置值确实来自外部时覆盖编辑器，
    // 避免用户正在输入时被自己的写回打断。
    function syncDateBlocksEditor() {
        if (!dateBlocksEditor)
            return;

        var stored = DateBlocks.blocksForStored(cfg_date_blocks, cfg_date_format);
        if (DateBlocks.serialize(stored) === DateBlocks.serialize(dateBlocksEditor.blocks))
            return;

        dateBlocksEditor.blocks = stored;
    }

    Component.onCompleted: syncDateBlocksEditor()
    onCfg_date_blocksChanged: syncDateBlocksEditor()
    onCfg_date_formatChanged: syncDateBlocksEditor()

    Item {
        id: fontColorProxy

        property color chosenColor: "#FFFFFF"
    }

    ColorDialog {
        id: colorDialog

        title: i18n("Choose Color")
        selectedColor: fontColorProxy.chosenColor
        onAccepted: fontColorProxy.chosenColor = selectedColor
    }

    ScrollView {
        id: scroll

        anchors.fill: parent
        // 内容与对话框边缘留白，避免贴边
        anchors.leftMargin: Kirigami.Units.gridUnit
        anchors.rightMargin: Kirigami.Units.gridUnit
        anchors.topMargin: Kirigami.Units.smallSpacing * 2
        anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            width: scroll.availableWidth
            spacing: 0

            Kirigami.FormLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: Kirigami.Units.gridUnit * 40
                Layout.alignment: Qt.AlignHCenter

                // ---------- 时间 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Time Settings")
                }

                FontSelector {
                    id: timeFontFamily

                    Kirigami.FormData.label: i18n("Font") + ":"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Font Size") + ":"

                    SpinBox {
                        id: timeFontSize

                        from: 1
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Letter Spacing") + ":"

                    SpinBox {
                        id: timeLetterSpacing

                        from: 0
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Word Spacing") + ":"

                    SpinBox {
                        id: timeWordSpacing

                        from: 0
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                // ---------- 日期 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Date Settings")
                }

                FontSelector {
                    id: dateFontFamily

                    Kirigami.FormData.label: i18n("Font") + ":"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Font Size") + ":"

                    SpinBox {
                        id: dateFontSize

                        from: 1
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Letter Spacing") + ":"

                    SpinBox {
                        id: dateLetterSpacing

                        from: 0
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                DateBlockEditor {
                    id: dateBlocksEditor

                    Kirigami.FormData.label: i18n("Date Format") + ":"
                    Layout.fillWidth: true
                    onBlocksEdited: function (updatedBlocks) {
                        root.cfg_date_blocks = DateBlocks.serialize(updatedBlocks);
                    }
                }

                // ---------- 边框 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Box Settings")
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Box spacing") + ":"

                    SpinBox {
                        id: framePadding

                        from: 0
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Border Width") + ":"

                    SpinBox {
                        id: frameBorderWidth

                        from: 0
                        to: 999
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                    }
                }

                // ---------- 边框阴影 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Frame Shadow")
                }

                CheckBox {
                    id: enableShadows

                    text: i18n("Enable shadow")
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Shadow Blur") + ":"

                    SpinBox {
                        id: frameShadowRadius

                        from: 0
                        to: 50
                        enabled: enableShadows.checked
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                        enabled: enableShadows.checked
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Shadow Opacity") + ":"

                    SpinBox {
                        id: frameShadowOpacity

                        from: 0
                        to: 100
                        enabled: enableShadows.checked
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "%"
                        enabled: enableShadows.checked
                    }
                }

                // ---------- 文字阴影 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Text Shadow")
                }

                CheckBox {
                    id: textShadowEnabled

                    text: i18n("Enable text shadow")
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Text Shadow Blur") + ":"

                    SpinBox {
                        id: textShadowRadius

                        from: 0
                        to: 20
                        enabled: textShadowEnabled.checked
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "px"
                        enabled: textShadowEnabled.checked
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Text Shadow Opacity") + ":"

                    SpinBox {
                        id: textShadowOpacity

                        from: 0
                        to: 100
                        enabled: textShadowEnabled.checked
                        Layout.preferredWidth: 140
                    }

                    Label {
                        text: "%"
                        enabled: textShadowEnabled.checked
                    }
                }

                // ---------- 颜色 ----------
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Color Settings")
                }

                CheckBox {
                    id: followSystemColor

                    text: i18n("Follow system color")
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Custom Color") + ":"
                    enabled: !followSystemColor.checked
                    spacing: 8

                    Rectangle {
                        implicitWidth: Kirigami.Units.gridUnit * 2
                        implicitHeight: Math.round(Kirigami.Units.gridUnit * 1.2)
                        radius: Kirigami.Units.smallSpacing
                        color: fontColorProxy.chosenColor
                        border.width: 1
                        border.color: Kirigami.Theme.disabledTextColor
                    }

                    Button {
                        text: i18n("Choose...")
                        onClicked: colorDialog.open()
                    }
                }
            }
        }
    }
}
