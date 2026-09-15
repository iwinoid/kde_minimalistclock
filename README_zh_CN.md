<p align="center">
  <img src="assets/logo.jpg" width=100/>
  <h2 align="center">KDE 极简时钟 Extended</h2>
  <p align="center">一款极简风格的时钟小部件！</p>
</p>

> [English](README.md) | 简体中文

<p align="center">
<a href="https://github.com/iwinoid/kde_minimalistclock/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/iwinoid/kde_minimalistclock/network"><img alt="GitHub forks" src="https://img.shields.io/github/forks/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/iwinoid/kde_minimalistclock/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/deepseek-ai/deepseek-harness"><img alt="powered by dsh" src="https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=for-the-badge&logo=deepseek&logoColor=white"></a>
</p>

<p align="center">
  <img src="assets/ss.png"/>
</p>

## 说明

本小部件已移植到 KDE Plasma 6，感谢 @dhruv8sh！

本分支（[iwinoid/kde_minimalistclock](https://github.com/iwinoid/kde_minimalistclock)）在原版基础上持续维护，新增了下面的功能。插件 ID 为 `com.github.iwinoid.minimalistclock`，可与上游原版同时安装，互不冲突。

## 与原版的区别

以下选项都在部件设置页（右键部件 → 配置）：

- **边框阴影** — 独立开关，模糊（0–50）、浓度（0–100%）可调
- **文字阴影** — 独立开关，模糊（0–20）、浓度（0–100%）可调，与边框阴影分开渲染
- **跟随系统配色**（默认开启）— 文字和边框跟随 `Kirigami.Theme.textColor`；关闭后可自选颜色
- **日期格式** — 11 个预设，外加可手输的文本框，支持任意 Qt 日期格式（`MM` 月、`dd` 日、`dddd` 星期）
- **字体与间距** — 时间和日期各自独立的字体、字号、字母/词间距；边框内边距与边框宽度可调
- **可滚动的设置页** — 六个分组，在小尺寸配置对话框里也能滚到底
- **简体中文汉化** — 完整 `zh_CN` 翻译，中文系统语言下自动生效
- **问题修复** — 字体选择可正确保存；时间数字在框内垂直居中

## 安装

#### 从本仓库安装（走这条）

1. 克隆本仓库
```sh
git clone https://github.com/iwinoid/kde_minimalistclock && cd kde_minimalistclock
```
2. 安装小部件
```sh
kpackagetool6 -t Plasma/Applet -i package
```

卸载/更新：
```sh
kpackagetool6 -t Plasma/Applet -r com.github.iwinoid.minimalistclock
kpackagetool6 -t Plasma/Applet -i package
```

#### KDE 商店（上游原版）

KDE 商店里的“Minimalist Clock”是上游原作者的版本，**不包含**上面的新功能。想要本分支的功能，请从本仓库安装。

## 兼容性

- KDE Plasma 6
- 阴影效果用到 `QtQuick.Effects.RectangularShadow`，需要 **Qt 6.9+**。Qt 版本过低时小部件照常运行，只是阴影不显示。

## 汉化说明

- 已提供 `zh_CN` 完整翻译（29 条，100%），位于 `package/translate/zh_CN.po`
- 编译后的翻译文件为 `package/contents/locale/zh_CN/LC_MESSAGES/plasma_applet_com.github.iwinoid.minimalistclock.mo`，随小部件打包分发，Plasma 5.37+ 会自动加载，无需手动安装
- 界面字符串覆盖：
  - `外观`、`选择颜色`
  - `边框设置`、`启用阴影`、`边框内边距`、`边框宽度`
  - `边框阴影`、`阴影模糊`、`阴影浓度`
  - `文字阴影`、`启用文字阴影`、`文字阴影模糊`、`文字阴影浓度`
  - `时间设置`、`字体`、`字体大小`、`字母间距`、`词间距`
  - `日期设置`、`日期与星期间距`、`日期格式`、`使用 Qt 日期格式：MM 月、dd 日、dddd 星期`
  - `颜色设置`、`跟随系统配色`、`自定义颜色`、`选择…`
  - 小部件名称 `极简时钟` 与描述 `适用于桌面的极简时钟小部件！`

### 重新生成翻译

```sh
cd package/translate
sh ./merge   # 扫描 QML 中的 i18n()，更新 template.pot 并合并到 zh_CN.po
sh ./build   # 编译 .po -> .mo 到 contents/locale
```

详见 [package/translate/ReadMe.md](package/translate/ReadMe.md)

## 原仓库

- 上游：https://github.com/prayag2/kde_minimalistclock
- 作者：Prayag Jain <prayagjain2@gmail.com>
- 许可：GPLv3
