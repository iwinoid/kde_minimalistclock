import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    // ---- 配置绑定（19 个，与 main.xml 一一对应，名字一个不动） ----
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
    property alias cfg_date_spacing: dateSpacing.value
    property alias cfg_date_font_size: dateFontSize.value
    property alias cfg_date_format: dateFormatField.editText

    // 颜色
    property alias cfg_follow_system_color: followSystemColor.checked
    property alias cfg_font_color: fontColorProxy.chosenColor

    Item { id: fontColorProxy; property color chosenColor: "#FFFFFF" }
    ColorDialog { id: colorDialog; title: i18n("Choose Color"); selectedColor: fontColorProxy.chosenColor; onAccepted: fontColorProxy.chosenColor = selectedColor }

    ScrollView {
        id: scroll
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Kirigami.FormLayout {
            width: scroll.availableWidth

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
                SpinBox { id: timeFontSize; from: 1; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Letter Spacing") + ":"
                SpinBox { id: timeLetterSpacing; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Word Spacing") + ":"
                SpinBox { id: timeWordSpacing; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
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
                SpinBox { id: dateFontSize; from: 1; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Letter Spacing") + ":"
                SpinBox { id: dateLetterSpacing; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Day and Date Spacing") + ":"
                SpinBox { id: dateSpacing; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            ColumnLayout {
                Kirigami.FormData.label: i18n("Date Format") + ":"
                ComboBox {
                    id: dateFormatField
                    Layout.fillWidth: true
                    editable: true
                    model: ["MM/dd dddd", "MM/dd ddd", "MM/dd", "dd/MM dddd", "dd MMM", "MMM dd", "MMM dd dddd", "dd MMM dddd", "MMM dd, dddd", "yyyy/MM/dd dddd", "dddd dd MMM"]
                }
                Label {
                    text: i18n("Use Qt date format: MM month, dd day, dddd weekday")
                    font.pixelSize: 11
                    opacity: 0.7
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            // ---------- 边框 ----------
            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Box Settings")
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Box spacing") + ":"
                SpinBox { id: framePadding; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Border Width") + ":"
                SpinBox { id: frameBorderWidth; from: 0; to: 999; Layout.preferredWidth: 140 }
                Label { text: "px" }
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
                SpinBox { id: frameShadowRadius; from: 0; to: 50; enabled: enableShadows.checked; Layout.preferredWidth: 140 }
                Label { text: "px"; enabled: enableShadows.checked }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Shadow Opacity") + ":"
                SpinBox { id: frameShadowOpacity; from: 0; to: 100; enabled: enableShadows.checked; Layout.preferredWidth: 140 }
                Label { text: "%"; enabled: enableShadows.checked }
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
                SpinBox { id: textShadowRadius; from: 0; to: 20; enabled: textShadowEnabled.checked; Layout.preferredWidth: 140 }
                Label { text: "px"; enabled: textShadowEnabled.checked }
            }
            RowLayout {
                Kirigami.FormData.label: i18n("Text Shadow Opacity") + ":"
                SpinBox { id: textShadowOpacity; from: 0; to: 100; enabled: textShadowEnabled.checked; Layout.preferredWidth: 140 }
                Label { text: "%"; enabled: textShadowEnabled.checked }
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
                Rectangle { width: 40; height: 22; radius: 4; color: fontColorProxy.chosenColor; border.width: 1; border.color: "#888" }
                Button { text: i18n("Choose..."); onClicked: colorDialog.open() }
            }
        }
    }
}
