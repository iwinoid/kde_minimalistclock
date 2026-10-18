import QtQuick
import org.kde.plasma.components as PlasmaComponents

// 纯字体下拉，不自带标签，由外层 Kirigami.FormLayout 通过
// Kirigami.FormData.label 统一配标签，避免双标签错位。
// 对外接口不变：property string fontFamily（cfg_* 直接绑定它）。
//
// 注意：必须用 PlasmaComponents 的 ComboBox。桌面风格的 QtQuick.Controls
// ComboBox 在 onCountChanged 里会对每个模型项做一次 FontMetrics 文字测量，
// 字体列表有 600+ 项时，打开设置页会因此卡住 2–3 秒。
//
// 模型用 { value, label } 对象：value 是配置里保存的字体名（"Default" 是
// 内置 Livvic 字体的哨兵值），label 用于显示，第一条 "Default" 走 i18n。
PlasmaComponents.ComboBox {
    id: root

    property string fontFamily

    readonly property var fontModel: {
        var families = Qt.fontFamilies();
        var model = [
            {
                "value": "Default",
                "label": i18n("Default")
            }
        ];
        for (var i = 0; i < families.length; i++)
            model.push({
                "value": families[i],
                "label": families[i]
            });
        return model;
    }

    model: fontModel
    textRole: "label"
    valueRole: "value"

    function syncIndex() {
        var idx = indexOfValue(root.fontFamily);
        if (idx === -1)
            idx = 0;

        if (currentIndex !== idx)
            currentIndex = idx;
    }

    Component.onCompleted: syncIndex()
    onFontFamilyChanged: syncIndex()
    // 只在用户真实操作下拉时回写 root.fontFamily（触发 cfg_* 保存）。
    // 不能用 onCurrentTextChanged：保存的字体临时不可用时会程序化回退到
    // Default，那样会把用户原来的字体名静默覆盖成 Default。
    onActivated: {
        if (currentValue !== undefined && currentValue !== root.fontFamily)
            root.fontFamily = currentValue;
    }
}
