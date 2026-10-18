#!/bin/sh
# Qt 6 lint 基线：qmllint 严格模式 + qmlformat 检查 + 翻译校验。
# 系统 PATH 上的 qml* 可能是 Qt 5，这里显式使用 Qt 6 工具。
set -eu

cd "$(dirname "$0")/.."
QTBIN=/usr/lib/qt6/bin
QML_FILES=$(find package -name '*.qml' | sort)
JS_FILES=$(find package -name '*.js' | sort)

status=0

echo "== qmllint =="
# shellcheck disable=SC2086
if ! lint_out=$("$QTBIN/qmllint" $QML_FILES $JS_FILES 2>&1); then
    printf '%s\n' "$lint_out"
    echo "qmllint: failed" >&2
    status=1
else
    printf '%s\n' "$lint_out"
    case "$lint_out" in
        *Warning:*|*Error:*)
            echo "qmllint: warnings or errors found" >&2
            status=1
            ;;
        *)
            echo "qmllint: clean"
            ;;
    esac
fi

echo "== qmlformat =="
for f in $QML_FILES; do
    if ! "$QTBIN/qmlformat" "$f" 2>/dev/null | diff -q "$f" - >/dev/null; then
        echo "qmlformat: would reformat $f (run scripts/format.sh)" >&2
        status=1
    fi
done
[ "$status" -eq 0 ] && echo "qmlformat: clean"

echo "== translations =="
if msgfmt --check --statistics package/translate/zh_CN.po -o /dev/null 2>&1; then
    echo "translations: OK"
else
    echo "translations: failed" >&2
    status=1
fi

exit "$status"
