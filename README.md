> English | [简体中文](README_zh_CN.md)

<p align="center">
  <img src="assets/logo.jpg" width=100/>
  <h2 align="center">Minimalist Clock Extended for KDE</h2>
  <p align="center">A minimalist looking clock widget!</center>
</p>

<p align="center">
<a href="https://github.com/iwinoid/kde_minimalistclock/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/iwinoid/kde_minimalistclock/network"><img alt="GitHub forks" src="https://img.shields.io/github/forks/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/iwinoid/kde_minimalistclock/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/iwinoid/kde_minimalistclock?color=%23234a37&style=for-the-badge"></a>
<a href="https://github.com/deepseek-ai/deepseek-harness"><img alt="powered by dsh" src="https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=for-the-badge&logo=deepseek&logoColor=white"></a>
</p>

<p align="center">
  <img src="assets/ss.png"/>
</p>

## Note

The applet has been ported to KDE Plasma 6, thanks to @dhruv8sh!

This is a maintained fork ([iwinoid/kde_minimalistclock](https://github.com/iwinoid/kde_minimalistclock)) with extra features listed below. Its plugin ID is `com.github.iwinoid.minimalistclock`, so it can be installed side by side with the upstream widget.

## Features (vs upstream)

All options live on the Appearance page (right-click the widget → Configure):

- **Frame shadow** — independent toggle, blur (0–50) and opacity (0–100%)
- **Text shadow** — independent toggle, blur (0–20) and opacity (0–100%), rendered separately from the frame shadow
- **Follow system color** (on by default) — text and frame follow `Kirigami.Theme.textColor`; turn it off to pick a custom color
- **Date blocks** — build the date line from visual blocks instead of picking a fixed format: year (`yyyy`/`yy`), month (`MMMM`/`MMM`/`MM`/`M`), day (`dd`/`d`), weekday (`dddd`/`ddd`) and free-text separators; add, remove and reorder blocks with a live preview. Existing `date_format` values migrate automatically.
- **Fonts & spacing** — separate font, size, letter/word spacing for time and date; frame padding and border width
- **Scrollable settings page** — six grouped sections that fit small config dialogs
- **Simplified Chinese localization** — full `zh_CN` translation, applied automatically under a Chinese locale
- **Fixes** — font selection is persisted correctly; time digits are vertically centered in the frame

## Roadmap

- [ ] **Per-block styling** — optional font family and size overrides for individual date blocks. Format composition itself ships in 0.2.0.

## Installation

#### From this repository (use this one)

1. Clone this repository
```sh
git clone https://github.com/iwinoid/kde_minimalistclock && cd kde_minimalistclock
```
2. Install the widget
```sh
kpackagetool6 -t Plasma/Applet -i package
```

Update / reinstall:
```sh
kpackagetool6 -t Plasma/Applet -r com.github.iwinoid.minimalistclock
kpackagetool6 -t Plasma/Applet -i package
```

#### KDE Store (upstream original)

The widget on the KDE Store ("Minimalist Clock") is the upstream version by Prayag Jain — it does **not** include the features above. If you want this fork, install from this repository.

## Compatibility

- KDE Plasma 6
- The shadow effects use `QtQuick.Effects.RectangularShadow`, which requires **Qt 6.9+**. On older Qt the widget still runs, but shadows will not render.

## Localization

Simplified Chinese (`zh_CN`) ships with the widget: source strings are in `package/translate/zh_CN.po`, compiled to `package/contents/locale/zh_CN/LC_MESSAGES/plasma_applet_com.github.iwinoid.minimalistclock.mo`. See [package/translate/ReadMe.md](package/translate/ReadMe.md) for how to rebuild or add a language. 中文说明见 [README_zh_CN.md](README_zh_CN.md)。

## Credits

Developed by DeepSeek V4.1 Flash.

<a href="https://github.com/deepseek-ai/deepseek-harness"><img alt="powered by dsh" src="https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=for-the-badge&logo=deepseek&logoColor=white"></a>

## Development

The widget targets Qt 6 / Plasma 6. On systems where `qml*` on `PATH` is Qt 5,
the helper scripts use the Qt 6 tools explicitly:

```sh
./scripts/lint.sh     # strict qmllint + qmlformat check + translation check
./scripts/format.sh   # qmlformat in place
```

`.qmllint.ini` and `.contextProperties.ini` keep the lint baseline at zero
warnings: translation context functions are declared as known context
properties, and KConfigXT dynamic keys are handled with a local lint directive.

## Upstream

- Upstream: https://github.com/prayag2/kde_minimalistclock
- Author: Prayag Jain <prayagjain2@gmail.com>
- License: GPLv3
