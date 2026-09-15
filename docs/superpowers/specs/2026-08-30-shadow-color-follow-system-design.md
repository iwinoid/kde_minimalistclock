# 阴影与跟随系统颜色设计 — Minimalist Clock

**日期:** 2026-08-30  
**作者:** iwinoid  
**状态:** 已确认，待实现

## 1. 背景与目标

- 现有 `enableShadows` 仅控制 `Plasmoid.backgroundHints` 二进制开关（`ShadowBackground/NoBackground`），不可调大小/浓度。
- 文字/边框颜色 `font_color` 已在 `main.xml` 但未在配置页暴露，始终 `#FFFFFF`。
- 目标：外阴影半径+浓度可调（默认开启），文字/边框颜色可选跟随 KDE 配色（默认开启跟随，关闭后可自定义），已做简中汉化，不破坏翻译。

## 2. 决策

选用 **方案 A：QtQuick.Effects.RectangularShadow**（Qt6 原生）+ `Kirigami.Theme.textColor`。

- 理由：Plasma 6 (Qt6) 原生、无 Qt5Compat 依赖、专为矩形设计，性能与效果最佳；回退可用 `MultiEffect`。

## 3. 配置模型 (`main.xml`)

组 `Appearance` 新增/保留：

| Entry | Type | Default | UI 范围 | 说明 |
|---|---|---|---|---|
| `enable_shadows` | Bool | true | CheckBox | 总开关 |
| `shadow_radius` | Int | 12 | 0-50 SpinBox | 模糊半径，映射 RectangularShadow.blur/radius |
| `shadow_opacity` | Int | 40 | 0-100 Slider | 浓度，映射 shadowColor alpha (0-1) |
| `follow_system_color` | Bool | true | CheckBox 默认勾选 | 跟随系统 |
| `font_color` | Color | #FFFFFF | ColorButton | 仅 follow=false 时可用 |

`shadow_radius/shadow_opacity` 的 `enabled` 绑定 `enableShadows`.

## 4. 配置页 (`configAppearance.qml`)

- `import QtQuick.Dialogs` 已有，新增 `import org.kde.kirigami as Kirigami` 仅 main.qml 需要，config 页无需。
- 在 `Box Settings` 段内、 `Border Width` 之后追加两行：
  - `阴影模糊半径` SpinBox
  - `阴影浓度` Slider (0-100) + 数值 Label "%"
- 新增一节 `颜色设置`：
  - `跟随系统配色` CheckBox (`cfg_follow_system_color`)
  - `自定义颜色` 行：Label + Rectangle 预览 + Button("选择") 打开 `ColorDialog`；`enabled: !followSystemColor.checked`
- 别名：`cfg_shadow_radius`, `cfg_shadow_opacity`, `cfg_follow_system_color`, `cfg_font_color`。
- 所有新增字符串包裹 `i18n()` 并加入 `zh_CN.po`：外观/阴影/颜色相关 6 条。

## 5. 主视图 (`main.qml`)

- `import org.kde.kirigami 2.15 as Kirigami`
- `import QtQuick.Effects` (RectangularShadow 在 QtQuick.Effects)
- 新增属性：
  ```qml
  property bool followSystemColor: plasmoid.configuration.follow_system_color
  property color effectiveFontColor: followSystemColor ? Kirigami.Theme.textColor : plasmoid.configuration.font_color
  property int shadowRadius: plasmoid.configuration.shadow_radius
  property int shadowOpacity: plasmoid.configuration.shadow_opacity
  ```
- 文字/边框：`color: effectiveFontColor`, `border.color: effectiveFontColor`
- 阴影：移除/弱化 `Plasmoid.backgroundHints` 阴影，改为在 `column` 之后/之前放置 `RectangularShadow`：
  ```qml
  RectangularShadow {
    visible: root.enableShadows
    anchors.fill: column // 或 rectangle + dateRow 的 bounding
    blur: root.shadowRadius
    color: Qt.rgba(0,0,0, root.shadowOpacity/100)
    offset: Qt.point(0,0)
    spread: 0
    // 或用 MultiEffect 回退
  }
  ```
  若 `RectangularShadow` 不可用，回退 `MultiEffect { shadowEnabled: enableShadows; shadowBlur: shadowRadius/50; shadowColor: ...; shadowOpacity }`
- 保持 `compactRepresentation` 不变。
- 性能：单一阴影，无动画，阴影仅在配置变更时重绘。

## 6. 边界与异常

- `Kirigami.Theme.textColor` 跟随系统深浅色自动切换，无需监听。
- `shadow_radius=0` 或 `shadow_opacity=0` 等同无阴影，即使 `enableShadows=true`。
- 缺失 `QtQuick.Effects` 时，`visible: false` 回退，避免 QML 报错；或用 `Loader` 按需加载。
- `font_color` 非法值回退 `#FFFFFF`（KConfig 默认）。
- 旧配置升级：新增键自动取默认，无需迁移。

## 7. 测试

- `qmllint` 全部 QML。
- `msgfmt/gettext` 验证 zh_CN。
- `kpackagetool6 -t Plasma/Applet -i` 安装，`plasmoidviewer` 快速预览阴影与颜色跟随。
- 桌面实测：开启/关闭跟随系统、切换浅/深色主题，文字同步；调半径 0/12/30、浓度 0/40/100，重启后仍持久。
- `desktop-appletsrc` 检查 `shadow_radius/shadow_opacity/follow_system_color` 持久化。

## 8. 非目标

- 不做文字投影（DropShadow）细调，仅外阴影。
- 不改字体选择已修复的持久化逻辑。
- 不新增翻译语言，仅 zh_CN。

## 9. 自检

- 无 TBD/占位，6 条新增 i18n 已列，架构与需求一致，范围聚焦单次交付。
