# 翻译说明

> 基于 Zren 的 i18n 脚本 v7/v23，适配 KDE Plasma 6 的 `metadata.json`

## 简体中文已完成

当前已提供 `zh_CN.po`（简体中文）完整翻译，覆盖：

- 外观设置、边框、时间/日期相关配置项
- 字体选择
- 小部件名称与描述

## 安装翻译

### 方式一：随小部件打包（推荐，Plasma 5.37+）

```sh
cd package/translate
sh ./build
# 然后重新安装小部件
kpackagetool6 -t Plasma/Applet -r com.github.iwinoid.minimalistclock 2>/dev/null; kpackagetool6 -t Plasma/Applet -i ../..
# 或 kpackagetool6 -i package
```

`build` 会将 `*.po` 编译为 `*.mo` 并输出到 `package/contents/locale/zh_CN/LC_MESSAGES/plasma_applet_com.github.iwinoid.minimalistclock.mo`，该目录会随 `.plasmoid` 一起分发，无需用户手动安装。

### 方式二：手动安装到系统

```sh
cd package/translate
sh ./build --restartplasma
# 会自动重启 plasmashell
```

翻译文件将被编译并可直接在本地 `~/.local/share/plasma/plasmoids/` 中生效（若已安装）。

## 新增/维护翻译

```sh
cd package/translate
sh ./merge   # 重新扫描 QML 中的 i18n() 并更新 template.pot 及所有 .po
```

- `template.pot` 为模板，包含所有待翻译字符串
- 复制 `template.pot` 为 `xx.po`（如 `ja.po`）即可新增语言
- 翻译完成后再次运行 `sh ./build` 生成 `.mo`

## 链接

- https://zren.github.io/kde/docs/widget/#translations-i18n
- https://github.com/Zren/plasma-applet-lib/tree/master/package/translate
- https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## 状态

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |      15 |       |
| zh_CN    |   15/15 |  100% |
