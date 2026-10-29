---@alias LiqUI_TableDataValue string|number

---@alias LiqUI_TableCellHandler fun(cellFrame: LiqUI_TableCellFrame, rowFrame: LiqUI_TableRowFrame, rowIndex: integer, columnIndex: integer, columnId: string|nil, rowData: LiqUI_TableDataRowExtended, cellData: LiqUI_TableDataCellExtended|nil)

---@alias LiqUI_TableCellClickHandler fun(cellFrame: LiqUI_TableCellFrame, rowFrame: LiqUI_TableRowFrame, rowIndex: integer, columnIndex: integer, columnId: string|nil, rowData: LiqUI_TableDataRowExtended, cellData: LiqUI_TableDataCellExtended|nil, button: string)

---@alias LiqUI_TableHeaderCellHandler fun(cellFrame: Button, columnIndex: integer, columnId: string|nil, column: LiqUI_TableOptionsColumn)

---@class LiqUI_TableDataCellExtended
---@field data LiqUI_TableDataValue|nil
---@field backgroundColor ColorRGBAData|nil
---@field onEnter LiqUI_TableCellHandler|nil
---@field onLeave LiqUI_TableCellHandler|nil
---@field onClick LiqUI_TableCellClickHandler|nil

---@alias LiqUI_TableDataCellValue LiqUI_TableDataValue|LiqUI_TableDataCellExtended

---@class LiqUI_TableDataRowExtended
---@field data LiqUI_TableDataCellValue[]
---@field height number|nil
---@field backgroundColor ColorRGBAData|nil
---@field indent number|nil
---@field skipStripe boolean|nil
---@field span boolean|nil
---@field padding number|nil
---@field paddingTop number|nil
---@field paddingBottom number|nil
---@field gapBefore number|nil
---@field gapAfter number|nil
---@field onEnter LiqUI_TableCellHandler|nil
---@field onLeave LiqUI_TableCellHandler|nil
---@field onClick LiqUI_TableCellClickHandler|nil

---@alias LiqUI_TableDataRow LiqUI_TableDataCellValue[]|LiqUI_TableDataRowExtended

---@alias LiqUI_TableData LiqUI_TableDataRow[]

---@class LiqUI_TableOptionsColumn
---@field id string
---@field dataIndex integer?
---@field headerText string|nil
---@field width number
---@field minWidth number?
---@field maxWidth number?
---@field resolvedWidth number?
---@field align "LEFT"|"CENTER"|"RIGHT"|nil
---@field hideable boolean|nil
---@field render? fun(cell: LiqUI_TableDataCellValue|nil, row: LiqUI_TableDataRowExtended, rowIndex: integer): LiqUI_TableDataValue|nil
---@field sorting LiqUI_TableOptionsColumnSorting|nil
---@field onEnter LiqUI_TableHeaderCellHandler|nil
---@field onLeave LiqUI_TableHeaderCellHandler|nil

---@class LiqUI_TableOptionsColumnSorting
---@field enabled boolean
---@field compare? fun(rowA: LiqUI_TableDataRowExtended, rowB: LiqUI_TableDataRowExtended, rowIndexA: integer, rowIndexB: integer): boolean

---@class LiqUI_TableOptionsHeader
---@field enabled boolean?
---@field sticky boolean?
---@field height number?
---@field fontObject string?
---@field backgroundAlpha number?
---@field resizable boolean?
---@field resizeHandleWidth number?
---@field defaultMinColumnWidth number?

---@class LiqUI_TableOptionsScroll
---@field horizontal boolean?

---@class LiqUI_TableOptionsRowStyle
---@field height number?
---@field highlight boolean?
---@field striped boolean?
---@field stripeColor ColorRGBAData?

---@class LiqUI_TableOptionsCellStyle
---@field padding number?
---@field highlight boolean?
---@field fontObject string?

---@class LiqUI_TableOptionsSorting
---@field enabled boolean
---@field defaultOrder "asc"|"desc"
---@field defaultCompare fun(rowA: LiqUI_TableDataRowExtended, rowB: LiqUI_TableDataRowExtended, rowIndexA: integer, rowIndexB: integer): boolean
---@field savedState LiqUI_TableSortState?
---@field onStateChanged fun(state: LiqUI_TableSortState)?

---@class LiqUI_TableOptions : LiqUI_NewElementOptions
---@field storage LiqUI_TableDB?
---@field columns LiqUI_TableOptionsColumn[]?
---@field header LiqUI_TableOptionsHeader?
---@field rowStyle LiqUI_TableOptionsRowStyle?
---@field cellStyle LiqUI_TableOptionsCellStyle?
---@field sorting LiqUI_TableOptionsSorting?
---@field scroll LiqUI_TableOptionsScroll?
---@field onLayoutChanged fun(frame: LiqUI_TableInstance, contentWidth: number, contentHeight: number, transient: boolean)?

---@class LiqUI_TableSortState
---@field columnId string|nil
---@field direction "asc"|"desc"|nil

---@class LiqUI_TableDB
---@field sortState LiqUI_TableSortState?
---@field hiddenColumns table<string, boolean>
---@field columnWidths table<string, number>?

---@class LiqUI_TableLayoutSize
---@field contentWidth number
---@field contentHeight number
---@field shownWidth number
---@field shownHeight number

---@class LiqUI_TableCellFrame : Button
---@field label FontString
---@field rowIndex integer
---@field columnIndex integer
---@field columnId string|nil
---@field tableFrame LiqUI_TableInstance
---@field resizeHandle Button?

---@class LiqUI_TableRowFrame : Frame
---@field cells table<integer, LiqUI_TableCellFrame>

---@class LiqUI_TableInstance : Frame
---@field options LiqUI_TableOptions
---@field data LiqUI_TableDataRowExtended[]
---@field headerRowFrame LiqUI_TableRowFrame|nil
---@field headerClipFrame Frame|nil
---@field rowFrames table<integer, LiqUI_TableRowFrame>
---@field scrollArea LiqUI_ScrollArea
---@field layoutSize LiqUI_TableLayoutSize
---@field db LiqUI_TableDB
---@field sortState LiqUI_TableSortState
---@field GetActiveColumns fun(self: LiqUI_TableInstance): LiqUI_TableOptionsColumn[]
---@field Render fun(self: LiqUI_TableInstance)
---@field ScrollToTop fun(self: LiqUI_TableInstance)
---@field SetData fun(self: LiqUI_TableInstance, data: LiqUI_TableData)
---@field SetColumns fun(self: LiqUI_TableInstance, columns: LiqUI_TableOptionsColumn[])
---@field SetColumnHidden fun(self: LiqUI_TableInstance, columnId: string, hidden: boolean)
---@field GetSortState fun(self: LiqUI_TableInstance): LiqUI_TableSortState
---@field SetSortState fun(self: LiqUI_TableInstance, columnId: string|nil, direction: "asc"|"desc"|nil)
---@field SetRowHeight fun(self: LiqUI_TableInstance, height: number)
---@field GetSize fun(self: LiqUI_TableInstance): number, number
---@field GetContentSize fun(self: LiqUI_TableInstance): number, number
---@field GetColumnWidth fun(self: LiqUI_TableInstance, columnId: string): number?
---@field SetColumnWidth fun(self: LiqUI_TableInstance, columnId: string, width: number, transient: boolean?)
---@field ResetColumnWidth fun(self: LiqUI_TableInstance, columnId: string)
---@field resizeState LiqUI_TableResizeState?

---@class LiqUI_TableResizeState
---@field columnId string
---@field startCursorX number
---@field startWidth number
