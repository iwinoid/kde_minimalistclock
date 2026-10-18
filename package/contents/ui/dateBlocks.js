.pragma library

// 日期行积木：纯逻辑模块，main.qml 与配置页共用。
//
// 一个积木只有两种形态：
//   { "token": "yyyy" }   日期元素，按 Qt 日期格式 token 渲染
//   { "text": " " }       自定义文本，原样渲染（分隔符、空格、中文单位等）
// 存储时序列化为 JSON 数组，放在 KConfig 的 date_blocks 键里。

var MAX_BLOCKS = 16

// Qt 支持的日期 token，长 token 必须排在前面（正则按顺序匹配）
var TOKENS = ["yyyy", "yy", "MMMM", "MMM", "MM", "M", "dddd", "ddd", "dd", "d"]
var TOKEN_PATTERN = /yyyy|yy|MMMM|MMM|MM|M|dddd|ddd|dd|d/g

// 月份名沿用旧版行为：固定英文，不随系统语言变化
var EN_SHORT = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
var EN_LONG = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

function defaultBlocks() {
    return [
        { token: "MM" },
        { text: "/" },
        { token: "dd" },
        { text: " " },
        { token: "dddd" }
    ]
}

function isToken(value) {
    return TOKENS.indexOf(value) !== -1
}

// 只保留合法积木；非法项直接丢弃，最多 MAX_BLOCKS 块
function normalize(blocks) {
    if (!blocks || blocks.length === undefined) {
        return []
    }
    var result = []
    for (var i = 0; i < blocks.length && result.length < MAX_BLOCKS; i++) {
        var block = blocks[i]
        if (!block) {
            continue
        }
        if (typeof block.token === "string" && isToken(block.token)) {
            result.push({ token: block.token })
        } else if (typeof block.text === "string") {
            result.push({ text: block.text })
        }
    }
    return result
}

// 解析 KConfig 里存的 JSON；无效或为空返回 null，由调用方回退到迁移/默认
function parse(storedValue) {
    if (!storedValue || typeof storedValue !== "string") {
        return null
    }
    try {
        var parsed = JSON.parse(storedValue)
        var blocks = normalize(parsed)
        return blocks.length ? blocks : null
    } catch (error) {
        return null
    }
}

function serialize(blocks) {
    return JSON.stringify(normalize(blocks))
}

// 旧版 date_format 字符串 -> 积木列表，例如 "dddd dd MMM" ->
// [{"token":"dddd"},{"text":" "},{"token":"dd"},{"text":" "},{"token":"MMM"}]
function fromLegacyFormat(format) {
    if (!format || typeof format !== "string") {
        return null
    }
    TOKEN_PATTERN.lastIndex = 0
    var blocks = []
    var lastEnd = 0
    var match
    while ((match = TOKEN_PATTERN.exec(format)) !== null) {
        if (match.index > lastEnd) {
            blocks.push({ text: format.substring(lastEnd, match.index) })
        }
        blocks.push({ token: match[0] })
        lastEnd = match.index + match[0].length
        if (blocks.length >= MAX_BLOCKS) {
            break
        }
    }
    if (lastEnd < format.length) {
        blocks.push({ text: format.substring(lastEnd) })
    }
    var normalized = normalize(blocks)
    return normalized.length ? normalized : null
}

// 渲染/编辑入口：优先新配置，其次从旧的 date_format 迁移，最后回退默认
function blocksForStored(storedBlocks, legacyFormat) {
    var fromStore = parse(storedBlocks)
    if (fromStore) {
        return fromStore
    }
    var migrated = fromLegacyFormat(legacyFormat)
    if (migrated) {
        return migrated
    }
    return defaultBlocks()
}

function tokenText(token, date) {
    var month = date.getMonth()
    if (token === "MMMM") {
        return EN_LONG[month]
    }
    if (token === "MMM") {
        return EN_SHORT[month]
    }
    return Qt.formatDate(date, token)
}

// 按积木顺序拼接当天日期；整体大写与旧版显示保持一致
function render(blocks, date) {
    if (!date) {
        date = new Date()
    }
    var items = normalize(blocks)
    if (!items.length) {
        items = defaultBlocks()
    }
    var text = ""
    for (var i = 0; i < items.length; i++) {
        var block = items[i]
        text += (block.token !== undefined) ? tokenText(block.token, date) : block.text
    }
    return text.toUpperCase()
}
