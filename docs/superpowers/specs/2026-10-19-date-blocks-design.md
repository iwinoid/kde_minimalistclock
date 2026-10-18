# 日期行积木设计 — Minimalist Clock Extended

**日期:** 2026-10-19
**作者:** iwinoid
**状态:** 已实现（0.2.0）

## 1. 背景与目标

旧版日期行只有一个 `date_format` 字符串加 11 个写死的预设：改格式要么选预设，要么手输整串 Qt 格式；
无法直观看到结果，也不利于以后做更灵活的排版。

目标：把日期行改成可视化积木——每个积木是一个日期元素（年/月/日/星期）或一段自定义文本，
可增删、排序，设置页里实时预览；渲染也按积木拼装，不再依赖写死的格式列表。

## 2. 数据模型

`main.xml` 新增 `date_blocks`（String，JSON 数组，默认空）：

```json
[
  { "token": "dddd" },
  { "text": " " },
  { "token": "dd" },
  { "text": " " },
  { "token": "MMM" }
]
```

- `token` 积木：按 Qt 日期格式 token 渲染
- `text` 积木：原样渲染（分隔符、空格、中文单位等）
- 上限 16 块，至少 1 块

支持的 token：`yyyy`、`yy`、`MMMM`、`MMM`、`MM`、`M`、`dddd`、`ddd`、`dd`、`d`。
`MMM`/`MMMM` 沿用旧版行为固定输出英文月份名，其余 token 交给 `Qt.formatDate` 跟随系统区域设置；
整行最终统一大写，与旧版显示一致。

纯逻辑放在 `package/contents/ui/dateBlocks.js`（`.pragma library`），
`main.qml` 与配置页共用：迁移、解析、序列化、渲染都在这一处。

## 3. 迁移与兼容

- `date_blocks` 为空时，从旧 `date_format` 字符串按 token 拆成积木；
  例：`"dddd dd MMM"` → `[dddd][ ][dd][ ][MMM]`
- 旧字段解析失败或为空 → 默认积木 `[MM][/][dd][ ][dddd]`（等于旧默认格式 `MM/dd dddd`）
- 不在打开设置页时自动写回；用户不动配置就保持旧值，下次继续按迁移规则渲染
- `date_format` 保留在 `main.xml` 里只作迁移来源，不再出现在设置页
- `date_spacing` 配置键保留但不再使用（间距由文本积木控制）

## 4. 设置页（DateBlockEditor.qml）

独立组件，放在「日期设置」分节的「日期格式」一行：

- 顶部实时预览（今天日期，大写）
- 积木列表：每行一个下拉框（日期元素或「自定义文本」）、自定义文本输入框、
  上移/下移/移除按钮
- 底部：「添加积木」（弹出元素菜单）、「恢复默认」
- 文本输入就地修改块对象，不重建列表，避免输入框失焦
- 数据单向流动：编辑器持有自己的 `blocks` 状态，用户改动通过 `blocksEdited`
  信号回传，配置页写入 `cfg_date_blocks`；配置页只在外部值确实变化时回写编辑器，
  避免打断用户输入

不使用 `property alias cfg_date_blocks: ...` 直接绑控件：
Plasma 写配置别名的时机早于控件建完，会造成回显丢失（与旧版 `date_format` 的坑同源）。
`cfg_date_blocks` 是普通 `property string`，由配置页显式同步。

## 5. 主视图（main.qml）

- 新增 `property var dateBlocks: DateBlocks.blocksForStored(date_blocks, date_format)`
- `updateDateTime()` 中日期部分改为 `DateBlocks.render(root.dateBlocks, curDate)`
- 三处触发：整分 tick、`onDateBlocksChanged`、首屏 `Component.onCompleted`
- 移除隐藏的 `dayLabel`，日期行收敛为单个 Label

## 6. 边界与异常

- 非法 JSON、非数组、未知 token：丢弃非法项；全部非法按未配置处理
- 用户删到只剩 1 块时禁止继续移除
- 超过 16 块时拒绝新增并裁剪
- 自定义文本可为空字符串

## 7. 验证

- `qmllint`：main.qml、configAppearance.qml、DateBlockEditor.qml、FontSelector.qml、config.qml、dateBlocks.js 全部 exit 0
- JS 离线测试（qml6 离屏，182 项）：21 种旧格式 × 4 个日期，新旧渲染逐字符一致；
  迁移结构、解析/序列化、非法输入回退、上限、大小写、英文月份
- 配置页集成测试（qml6 离屏，16 项）：迁移、写回、增删/排序、文本就地编辑、预览刷新、上下限
- 实际安装：`kpackagetool6 -u` 升级到 0.2.0，plasmashell 重启后 journal 无 QML 错误
- 视觉验证：`plasmoidviewer` 使用用户当前配置（160px Noto Sans / 36px Maple Mono NF CN、
  内边距 25、边框 10、无阴影）渲染正常

## 8. 非目标

- 每块独立字体/字号：结构已可扩展，留到下一期（见 README Roadmap）
- 拖拽排序：配置对话框里用按钮排序更稳
- 时间行的积木化：本次只处理日期行

## 9. 后续修复（0.2.x）

### 设置页打开慢（~3 秒）

根因不在积木逻辑：Plasma 桌面风格 `org.kde.desktop` 的 `ComboBox` 在
`onCountChanged` 里会对每个模型项调用一次 `FontMetrics.boundingRect()` 计算宽度。
字体选择器把 600+ 个字体直接塞进 `ComboBox.model`，两个选择器合计上千次文字测量，
导致设置页卡顿 2–3 秒（隔离实验：去掉大模型后从 ~3.0s 降到 ~0.5s）。

修复：`FontSelector.qml` 改用 `org.kde.plasma.components` 的 `ComboBox`
（模板实现，不做逐项文字测量）。实测配置窗口出现时间从 ~3.0s 降到 ~0.57s。

### 设置页留白与积木区布局

- `ScrollView` 增加左右 `Kirigami.Units.gridUnit`、上下 `smallSpacing * 2` 边距，
  内容不再贴对话框边缘
- 积木区：预览改为带背景/描边的框；token 块用等宽占位让各行按钮列对齐；
  补「积木按从左到右拼接」提示；ComboBox 宽度改用 `Kirigami.Units` 推导
- 颜色预览块改用 `implicitWidth/implicitHeight`，消除 Qt6 qmllint 的
  `Quick.layout-positioning` 警告；`DateBlockEditor.qml` 加
  `pragma ComponentBehavior: Bound`
- 表单外包一层 `ColumnLayout`，`Layout.maximumWidth: Kirigami.Units.gridUnit * 40`
  并水平居中：对话框被拉宽/最大化时内容不再拉伸到全宽，默认窄宽度下仍填满
- 预览行从 `DateBlockEditor` 移入配置页的 `Kirigami.FormLayout`：标签与「字体：」等
  同一列对齐；编辑器每次改动写回 `cfg_date_blocks`，配置页的 `previewText` 绑定
  随即刷新
- i18n 复查：47 条、100%。`FontSelector` 的 `Default` 改成 `{ value, label }`
  对象模型后可翻译（保存值仍是 `Default`）；`Choose...` 统一为 KDE 省略号
  `Choose…`；年积木中文统一为「年（四位数字）/年（两位数字）」；面板提示按英文
  原文语气改为「面板太小，放不下我！」
- Qt 6 lint 基线：新增 `.qmllint.ini`（项目级 qmllint 配置）与
  `.contextProperties.ini`（把 i18n/xi18n 家族声明为已知上下文属性，真正消除
  UnqualifiedAccess 误报）；`main.qml` 加 `pragma ComponentBehavior: Bound`、
  移除未用 import、把 `updateDateTime` 调用限定为 `fullRoot.`，KConfigXT 动态键
  用文件级 `// qmllint disable missing-property` 处理。`scripts/lint.sh`
  （qmllint + qmlformat + 翻译）现为 0 警告 0 信息。
