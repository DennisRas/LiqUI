---@class LiqUI_TableColumnSorting
---@field enabled boolean
---@field compare? fun(a: LiqUI_TableDataRow, b: LiqUI_TableDataRow): boolean

---@class LiqUI_TableConfig
---@field name string?
---@field header LiqUI_TableConfigHeader?
---@field rows LiqUI_TableConfigRows?
---@field columns LiqUI_TableConfigColumns?
---@field cells LiqUI_TableConfigCells?
---@field sorting LiqUI_TableSortConfig?
---@field data LiqUI_TableData?

---@class LiqUI_TableConfigCells
---@field padding number?
---@field highlight boolean?
---@field fontObject string?

---@class LiqUI_TableConfigColumns
---@field width number?
---@field highlight boolean?
---@field striped boolean?

---@class LiqUI_TableConfigHeader
---@field enabled boolean?
---@field sticky boolean?
---@field height number?

---@class LiqUI_TableConfigRows
---@field height number?
---@field highlight boolean?
---@field striped boolean?

---@class LiqUI_TableData
---@field columns LiqUI_TableDataColumn[]?
---@field rows LiqUI_TableDataRow[]

---@class LiqUI_TableBuildDataOptions
---@field includeHeader boolean?

---@class LiqUI_TableDataColumn
---@field id string?
---@field headerText string?
---@field width number
---@field align "LEFT"|"CENTER"|"RIGHT"|nil
---@field onEnter function?
---@field onLeave function?
---@field hideable boolean?
---@field render fun(data: table): LiqUI_TableDataRowColumn?
---@field sorting LiqUI_TableColumnSorting?

---@class LiqUI_TableDataRow
---@field columns LiqUI_TableDataRowColumn[]
---@field data table|nil
---@field backgroundColor table|nil
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class LiqUI_TableDataRowColumn
---@field text string?
---@field backgroundColor table|nil
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class LiqUI_TableFrame : Frame
---@field config LiqUI_TableConfig
---@field db LiqUI_TableDb|nil
---@field rows table
---@field data LiqUI_TableData
---@field scrollFrame LiqUI_ScrollArea
---@field contentWidth number
---@field contentHeight number
---@field sortState LiqUI_TableSortState

---@class LiqUI_TableDb
---@field sortState LiqUI_TableSortState?
---@field columnWidths table<string, number>?

---@class LiqUI_TableManager

---@class LiqUI_TableSortConfig
---@field enabled boolean
---@field defaultOrder "asc"|"desc"
---@field defaultCompare fun(a: LiqUI_TableDataRow, b: LiqUI_TableDataRow): boolean
---@field savedState LiqUI_TableSortState?
---@field onStateChanged? fun(state: LiqUI_TableSortState)

---@class LiqUI_TableSortState
---@field columnId string|nil
---@field direction "asc"|"desc"|nil
