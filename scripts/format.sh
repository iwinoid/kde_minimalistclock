#!/bin/sh
# 用 Qt 6 qmlformat 格式化全部 QML。
set -eu

cd "$(dirname "$0")/.."
for f in $(find package -name '*.qml' | sort); do
    /usr/lib/qt6/bin/qmlformat -i "$f"
done
echo "qmlformat: formatted all QML files"
