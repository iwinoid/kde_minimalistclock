pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "dateBlocks.js" as DateBlocks
import org.kde.kirigami as Kirigami

// 日期行积木编辑器：实时预览 + 可增删/排序的积木列表。
// blocks 是编辑器自己的状态：配置页在初始化/外部变更时写入，用户改动通过
// blocksEdited 回传。文本编辑只改当前块对象，避免重建 TextField 打断输入。
ColumnLayout {
    id: root

    property var blocks: []
    readonly property int maxBlocks: DateBlocks.MAX_BLOCKS
    readonly property int customChoiceIndex: tokenChoices.length - 1
    property string previewText: ""
    // 下拉框选项；最后一项是自定义文本
    readonly property var tokenChoices: [{
        "token": "yyyy",
        "label": i18n("Year (four digits)")
    }, {
        "token": "yy",
        "label": i18n("Year (two digits)")
    }, {
        "token": "MMMM",
        "label": i18n("Month (full name)")
    }, {
        "token": "MMM",
        "label": i18n("Month (short name)")
    }, {
        "token": "MM",
        "label": i18n("Month (two digits)")
    }, {
        "token": "M",
        "label": i18n("Month (number)")
    }, {
        "token": "dddd",
        "label": i18n("Weekday (full name)")
    }, {
        "token": "ddd",
        "label": i18n("Weekday (short name)")
    }, {
        "token": "dd",
        "label": i18n("Day (two digits)")
    }, {
        "token": "d",
        "label": i18n("Day (number)")
    }, {
        "token": "",
        "label": i18n("Custom text")
    }]

    signal blocksEdited(var updatedBlocks)

    function refreshPreview() {
        previewText = DateBlocks.render(blocks, new Date());
    }

    function commitBlocks(updatedBlocks) {
        blocks = updatedBlocks;
        refreshPreview();
        blocksEdited(updatedBlocks);
    }

    function choiceIndexFor(token) {
        for (var i = 0; i < tokenChoices.length; i++) {
            if (tokenChoices[i].token === token)
                return i;

        }
        return customChoiceIndex;
    }

    function setBlockToken(blockIndex, token) {
        var updated = blocks.slice();
        updated[blockIndex] = {
            "token": token
        };
        commitBlocks(updated);
    }

    function setBlockCustom(blockIndex, text) {
        var updated = blocks.slice();
        updated[blockIndex] = {
            "text": text
        };
        commitBlocks(updated);
    }

    // 文本块就地修改：不替换数组，避免 Repeater 重建导致输入框失焦。
    function setBlockText(blockIndex, text) {
        if (!blocks[blockIndex] || blocks[blockIndex].text === text)
            return ;

        blocks[blockIndex].text = text;
        refreshPreview();
        blocksEdited(blocks.slice());
    }

    function addBlock(token) {
        if (blocks.length >= maxBlocks)
            return ;

        var updated = blocks.slice();
        updated.push(token === "" ? {
            "text": " "
        } : {
            "token": token
        });
        commitBlocks(updated);
    }

    function moveBlock(blockIndex, offset) {
        var target = blockIndex + offset;
        if (target < 0 || target >= blocks.length)
            return ;

        var updated = blocks.slice();
        var moved = updated[blockIndex];
        updated[blockIndex] = updated[target];
        updated[target] = moved;
        commitBlocks(updated);
    }

    function removeBlock(blockIndex) {
        if (blocks.length <= 1)
            return ;

        var updated = blocks.slice();
        updated.splice(blockIndex, 1);
        commitBlocks(updated);
    }

    spacing: Kirigami.Units.smallSpacing
    Component.onCompleted: {
        if (!blocks.length)
            blocks = DateBlocks.defaultBlocks();

        refreshPreview();
    }
    onBlocksChanged: refreshPreview()

    // ---- 实时预览 ----
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Label {
            text: i18n("Preview:")
            opacity: 0.7
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: previewLabel.implicitHeight + Kirigami.Units.largeSpacing * 2
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)

            Label {
                id: previewLabel

                anchors.centerIn: parent
                width: parent.width - Kirigami.Units.largeSpacing * 2
                text: root.previewText
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }

        }

    }

    // ---- 积木列表 ----
    Repeater {
        model: root.blocks

        RowLayout {
            id: blockRow

            required property int index
            required property var modelData
            readonly property bool isCustom: modelData.token === undefined

            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            ComboBox {
                Layout.preferredWidth: Kirigami.Units.gridUnit * 11
                model: root.tokenChoices
                textRole: "label"
                currentIndex: blockRow.isCustom ? root.customChoiceIndex : root.choiceIndexFor(blockRow.modelData.token)
                onActivated: {
                    var token = root.tokenChoices[currentIndex].token;
                    if (token === "")
                        root.setBlockCustom(blockRow.index, blockRow.isCustom ? blockRow.modelData.text : " ");
                    else
                        root.setBlockToken(blockRow.index, token);
                }
            }

            TextField {
                Layout.fillWidth: true
                visible: blockRow.isCustom
                text: blockRow.isCustom ? blockRow.modelData.text : ""
                placeholderText: i18n("Separator or text")
                onTextEdited: root.setBlockText(blockRow.index, text)
            }

            // token 块没有输入框，用等宽占位让各行的按钮列保持对齐
            Item {
                Layout.fillWidth: true
                visible: !blockRow.isCustom
            }

            ToolButton {
                icon.name: "go-up"
                enabled: blockRow.index > 0
                onClicked: root.moveBlock(blockRow.index, -1)
                ToolTip.text: i18n("Move up")
                ToolTip.visible: hovered
                Accessible.name: i18n("Move up")
            }

            ToolButton {
                icon.name: "go-down"
                enabled: blockRow.index < root.blocks.length - 1
                onClicked: root.moveBlock(blockRow.index, 1)
                ToolTip.text: i18n("Move down")
                ToolTip.visible: hovered
                Accessible.name: i18n("Move down")
            }

            ToolButton {
                icon.name: "list-remove"
                enabled: root.blocks.length > 1
                onClicked: root.removeBlock(blockRow.index)
                ToolTip.text: i18n("Remove block")
                ToolTip.visible: hovered
                Accessible.name: i18n("Remove block")
            }

        }

    }

    // ---- 添加 / 恢复默认 ----
    Label {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        text: i18n("Blocks are joined from left to right.")
        opacity: 0.7
        wrapMode: Text.WordWrap
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Button {
            text: i18n("Add block")
            icon.name: "list-add"
            enabled: root.blocks.length < root.maxBlocks
            onClicked: addBlockMenu.popup()
        }

        Button {
            text: i18n("Reset to default")
            icon.name: "edit-undo"
            onClicked: root.commitBlocks(DateBlocks.defaultBlocks())
        }

        Item {
            Layout.fillWidth: true
        }

    }

    Menu {
        id: addBlockMenu

        Repeater {
            model: root.tokenChoices

            MenuItem {
                required property var modelData

                text: modelData.label
                onTriggered: root.addBlock(modelData.token)
            }

        }

    }

}
