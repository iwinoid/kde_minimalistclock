import QtQuick
import QtQuick.Controls

// 纯字体下拉，不自带标签，由外层 Kirigami.FormLayout 通过
// Kirigami.FormData.label 统一配标签，避免双标签错位。
// 对外接口不变：property string fontFamily（cfg_* 直接绑定它）。
ComboBox {
    id: root

    property string fontFamily

    model: getFontsModel()

    function getFontsModel() {
        var arr = Qt.fontFamilies()
        arr.unshift("Default")
        return arr
    }

    Component.onCompleted: {
        var idx = model.indexOf(root.fontFamily)
        currentIndex = idx !== -1 ? idx : 0
    }

    // 外部 (ConfigModel cfg_*) 写入 fontFamily 时，同步下拉选中项
    onFontFamilyChanged: {
        if (!model)
            return
        var idx = model.indexOf(fontFamily)
        if (idx === -1)
            idx = 0 // 找不到（如字体已卸载或首次安装）回退 Default
        if (currentIndex !== idx)
            currentIndex = idx
    }

    // 只在用户真实操作下拉时回写 root.fontFamily（触发 cfg_* 保存）。
    // 不能用 onCurrentTextChanged：保存的字体临时不可用时会程序化回退到
    // Default，那样会把用户原来的字体名静默覆盖成 Default。
    onActivated: {
        if (currentText !== root.fontFamily)
            root.fontFamily = currentText
    }
}
