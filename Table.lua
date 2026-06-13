---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_TableManager
local Table = {}
LiqUI.Table = Table

local BindScrollBoxMouseWheel = LiqUI.Utils.BindScrollBoxMouseWheel
local CreateScrollArea = LiqUI.Utils.CreateScrollArea
local SetBackgroundColor = LiqUI.Utils.SetBackgroundColor
local SetHighlightColor = LiqUI.Utils.SetHighlightColor
local TableFilter = LiqUI.Utils.TableFilter
local TableForEach = LiqUI.Utils.TableForEach
local TableMergeConfig = LiqUI.Utils.TableMergeConfig

local defaultColumnWidth = LiqUI.Constants.layout.sizes.column
local HEADER_ROW_INDEX = 0

---@param value table
---@return boolean
local function isExtendedTable(value)
  if type(value) ~= "table" then
    return false
  end
  for key in pairs(value) do
    if type(key) == "string" then
      return true
    end
  end
  return false
end

---@param cellValue LiqUI_TableDataCellValue|nil
---@return LiqUI_TableDataCellExtended
local function normalizeCell(cellValue)
  if cellValue == nil then
    return { data = nil }
  end
  if type(cellValue) ~= "table" then
    return { data = cellValue }
  end
  if not isExtendedTable(cellValue) then
    return { data = cellValue }
  end
  ---@type LiqUI_TableDataCellExtended
  local normalized = { data = cellValue.data }
  for key, value in pairs(cellValue) do
    if type(key) == "string" and key ~= "data" then
      normalized[key] = value
    end
  end
  return normalized
end

---@param row LiqUI_TableDataRow
---@return LiqUI_TableDataRowExtended
local function normalizeRow(row)
  local cells
  ---@type LiqUI_TableDataRowExtended
  local normalized = { data = {} }

  if isExtendedTable(row) then
    cells = row.data or {}
    for key, value in pairs(row) do
      if type(key) == "string" and key ~= "data" then
        normalized[key] = value
      end
    end
  else
    cells = row
  end

  for columnIndex, cellValue in ipairs(cells) do
    normalized.data[columnIndex] = normalizeCell(cellValue)
  end
  return normalized
end

---@param data LiqUI_TableData
---@return LiqUI_TableStoredData
local function normalizeData(data)
  ---@type LiqUI_TableStoredData
  local normalized = {}
  for rowIndex = 1, #data do
    normalized[rowIndex] = normalizeRow(data[rowIndex])
  end
  return normalized
end

---@param frame Frame
---@param color ColorTable|nil
local function applyBackgroundColor(frame, color)
  if color then
    SetBackgroundColor(frame, color.r, color.g, color.b, color.a)
  else
    SetBackgroundColor(frame, 0, 0, 0, 0)
  end
end

---@param tableFrame LiqUI_TableFrame
---@return LiqUI_TableConfigColumn[]
local function activeColumns(tableFrame)
  local columns = tableFrame.config.columns
  if not columns then
    return {}
  end
  if tableFrame.db and tableFrame.db.hiddenColumns then
    return Table.FilterColumns(columns, tableFrame.db.hiddenColumns)
  end
  return columns
end

---@param columns LiqUI_TableConfigColumn[]
---@param hiddenColumns table<string, boolean>?
---@return LiqUI_TableConfigColumn[]
function Table.FilterColumns(columns, hiddenColumns)
  if not hiddenColumns then
    return columns
  end
  return TableFilter(columns, function(column)
    return column.id and not hiddenColumns[column.id]
  end)
end

---@param columns LiqUI_TableConfigColumn[]
---@param sorting LiqUI_TableConfigSorting|nil
local function validateSortingColumns(columns, sorting)
  if not sorting or not sorting.enabled then
    return
  end
  for columnIndex, column in ipairs(columns) do
    if not column.sorting then
      error(format('LiqUI Table: column #%d ("%s") must define sorting', columnIndex, tostring(column.id)), 2)
    end
  end
end

---@param instance LiqUI_Instance
function Table:Embed(instance)
  instance.Table = LiqUI.BindManager(instance, self, { frames = {} })
end

---Create a new table frame
---@param config LiqUI_TableConfig?
---@return LiqUI_TableFrame
function Table:New(config)
  if not self.db then
    error("LiqUI.Table:New requires a LiqUI instance", 2)
  end
  if not config or not config.name or config.name == "" then
    error("LiqUI Table: config.name is required", 2)
  end

  self.db.tables[config.name] = self.db.tables[config.name] or {}
  local db = self.db.tables[config.name]
  db.hiddenColumns = db.hiddenColumns or {}

  local frameSuffix = self.name:gsub("[^%w]", "") .. config.name:gsub("[^%w]", "")
  ---@type LiqUI_TableFrame
  local frame = CreateFrame("Frame", "LiqUITable" .. frameSuffix) ---@diagnostic disable-line:assign-type-mismatch

  ---@type LiqUI_TableConfig
  local defaultConfig = {
    header = {
      enabled = true,
      sticky = false,
      height = LiqUI.Constants.layout.sizes.header,
    },
    rowStyle = {
      height = LiqUI.Constants.layout.sizes.row,
      highlight = true,
      striped = true,
    },
    cellStyle = {
      padding = LiqUI.Constants.layout.sizes.padding,
      highlight = false,
      fontObject = "GameFontHighlight",
    },
    sorting = {
      enabled = false,
      defaultOrder = "desc",
      defaultCompare = function()
        return false
      end,
    },
  }
  ---@type LiqUI_TableConfig
  local mergedConfig = {}
  TableMergeConfig(mergedConfig, defaultConfig)
  TableMergeConfig(mergedConfig, config or {})
  if config and config.rows and not mergedConfig.rowStyle then
    mergedConfig.rowStyle = config.rows
  end
  if config and config.cells and not mergedConfig.cellStyle then
    mergedConfig.cellStyle = config.cells
  end
  frame.config = mergedConfig

  do
    local sorting = frame.config.sorting
    if sorting and sorting.enabled then
      if type(sorting.defaultCompare) ~= "function" then
        error("LiqUI Table: sorting.enabled requires sorting.defaultCompare", 2)
      end
      if sorting.defaultOrder ~= "asc" and sorting.defaultOrder ~= "desc" then
        error("LiqUI Table: sorting.enabled requires sorting.defaultOrder to be \"asc\" or \"desc\"", 2)
      end
    end
  end

  frame.data = {}
  frame.rows = {}
  ---@type LiqUI_TableSortState
  frame.sortState = { columnId = nil, direction = nil }
  frame.db = db
  frame.layoutSize = { shownWidth = 0, shownHeight = 0 }

  if db then
    frame.config.sorting = frame.config.sorting or {}
    if db.sortState then
      frame.config.sorting.savedState = db.sortState
    end
    if not frame.config.sorting.onStateChanged then
      frame.config.sorting.onStateChanged = function(state)
        db.sortState = state
      end
    end
  end

  ---@param rowIndex integer
  ---@return boolean
  local function isHeaderRow(rowIndex)
    return rowIndex == HEADER_ROW_INDEX
  end

  ---@param columnId string|nil
  ---@return number|nil
  local function columnIndexForId(columnId)
    if not columnId then
      return nil
    end
    local columns = activeColumns(frame)
    for columnIndex, column in ipairs(columns) do
      if column.id == columnId then
        return columnIndex
      end
    end
    return nil
  end

  local function setSortStateToDefault()
    local state = frame.sortState
    state.columnId = nil
    state.direction = nil
  end

  local function validateSortState()
    local sorting = frame.config.sorting
    if not sorting or not sorting.enabled then
      return
    end
    local state = frame.sortState
    if not state then
      return
    end
    if state.columnId and not columnIndexForId(state.columnId) then
      setSortStateToDefault()
      if sorting.onStateChanged then
        sorting.onStateChanged(state)
      end
      return
    end
    if state.columnId then
      if state.direction ~= "asc" and state.direction ~= "desc" then
        state.direction = (sorting.defaultOrder == "asc") and "asc" or "desc"
      end
    else
      state.direction = nil
    end
  end

  do
    local sorting = frame.config.sorting
    local saved = sorting and sorting.savedState
    if sorting and sorting.enabled and saved and type(saved.columnId) == "string" and saved.columnId ~= "" then
      frame.sortState.columnId = saved.columnId
      if saved.direction == "asc" or saved.direction == "desc" then
        frame.sortState.direction = saved.direction
      else
        frame.sortState.direction = (sorting.defaultOrder == "asc") and "asc" or "desc"
      end
    else
      setSortStateToDefault()
    end
  end

  local function notifySortStateChanged()
    local sorting = frame.config.sorting
    if sorting and sorting.onStateChanged then
      sorting.onStateChanged(frame.sortState)
    end
  end

  local rowHeight = frame.config.rowStyle.height or LiqUI.Constants.layout.sizes.row
  frame.scrollArea = CreateScrollArea(frame, {
    name = "$parentScrollArea",
    vertical = true,
    horizontal = false,
    wheelPanExtent = rowHeight,
  })

  local function scrollToTopAfterHeaderSort()
    C_Timer.After(0, function()
      frame:ScrollToTop()
    end)
  end

  ---@param rowIndex integer
  ---@return LiqUI_TableRowFrame
  local function createRow(rowIndex)
    local parent = frame
    if not isHeaderRow(rowIndex) then
      parent = frame.scrollArea.content
    end
    ---@type LiqUI_TableRowFrame
    local rowFrame = CreateFrame("Frame", "$parentRow" .. rowIndex, parent)
    rowFrame.cells = {}
    BindScrollBoxMouseWheel(rowFrame, frame.scrollArea:GetWheelScrollBox())
    frame.rows[rowIndex] = rowFrame
    return rowFrame
  end

  ---@param rowFrame LiqUI_TableRowFrame
  ---@param name string
  ---@param sortingEnabled boolean
  ---@return LiqUI_TableCellFrame
  local function createCell(rowFrame, name, sortingEnabled)
    ---@type LiqUI_TableCellFrame
    local cellFrame = CreateFrame("Button", name, rowFrame)
    cellFrame.label = cellFrame:CreateFontString("$parentLabel", "OVERLAY")
    local cellStyle = frame.config.cellStyle
    cellFrame.label:SetFontObject((cellStyle and cellStyle.fontObject) or "GameFontHighlight")
    cellFrame.label:SetWordWrap(false)
    cellFrame.tableFrame = frame
    BindScrollBoxMouseWheel(cellFrame, frame.scrollArea:GetWheelScrollBox())
    if sortingEnabled then
      cellFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    cellFrame:SetScript("OnEnter", function(self)
      self.tableFrame:OnCellEnter(self)
    end)
    cellFrame:SetScript("OnLeave", function(self)
      self.tableFrame:OnCellLeave(self)
    end)
    cellFrame:SetScript("OnClick", function(self, button)
      self.tableFrame:OnCellClick(self, button)
    end)
    return cellFrame
  end

  local function applySort()
    local sorting = frame.config.sorting
    if not sorting or not sorting.enabled then
      return
    end

    local data = frame.data
    if not data or #data == 0 then
      return
    end

    local state = frame.sortState
    local sortColumnIndex = columnIndexForId(state.columnId)
    if state.columnId and state.direction and not sortColumnIndex then
      return
    end

    local indices = {}
    for rowIndex = 1, #data do
      indices[rowIndex] = rowIndex
    end

    local columnSort = state.columnId and state.direction and sortColumnIndex
    if not columnSort then
      table.sort(indices, function(rowIndexA, rowIndexB)
        return sorting.defaultCompare(data[rowIndexA], data[rowIndexB], rowIndexA, rowIndexB)
      end)
    else
      local ascending = state.direction == "asc"
      local columns = activeColumns(frame)
      local columnConfig = columns[sortColumnIndex]
      if not columnConfig or not columnConfig.sorting then
        error(format("LiqUI Table: column \"%s\" must define sorting", tostring(columnConfig and columnConfig.id)), 2)
      end
      local columnSorting = columnConfig.sorting
      if not columnSorting or not columnSorting.enabled then
        error(format("LiqUI Table: column \"%s\" is not sortable", tostring(columnConfig.id)), 2)
      end
      local compare = columnSorting.compare
      if type(compare) ~= "function" then
        error(format("LiqUI Table: column \"%s\" must define sorting.compare", tostring(columnConfig.id)), 2)
      end
      table.sort(indices, function(rowIndexA, rowIndexB)
        if ascending then
          return compare(data[rowIndexA], data[rowIndexB], rowIndexA, rowIndexB)
        end
        return compare(data[rowIndexB], data[rowIndexA], rowIndexB, rowIndexA)
      end)
    end

    ---@type LiqUI_TableData
    local sortedData = {}
    for position = 1, #indices do
      sortedData[position] = data[indices[position]]
    end
    frame.data = sortedData
  end

  local function renderTable()
    local config = frame.config
    local columns = activeColumns(frame)
    local data = frame.data or {}
    local headerConfig = config.header
    local rowStyle = config.rowStyle
    local cellStyle = config.cellStyle
    local defaultRowHeight = rowStyle.height or LiqUI.Constants.layout.sizes.row
    local headerHeight = headerConfig.height or LiqUI.Constants.layout.sizes.header
    local padding = (cellStyle and cellStyle.padding) or LiqUI.Constants.layout.sizes.padding
    local sortingConfig = config.sorting

    local contentWidth = 0
    for columnIndex = 1, #columns do
      contentWidth = contentWidth + (columns[columnIndex].width or defaultColumnWidth)
    end

    TableForEach(frame.rows, function(rowFrame)
      rowFrame:Hide()
    end)

    local offsetY = 0
    local scrollContentHeight = 0
    if headerConfig.enabled and not headerConfig.sticky then
      scrollContentHeight = headerHeight
    end

    local scrollArea = frame.scrollArea
    scrollArea:SetParent(frame)
    if headerConfig.enabled and headerConfig.sticky then
      scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -headerHeight)
      scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    else
      scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
      scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    end

    if headerConfig.enabled then
      local rowFrame = frame.rows[HEADER_ROW_INDEX]
      if not rowFrame then
        rowFrame = createRow(HEADER_ROW_INDEX)
      end
      rowFrame:SetHeight(headerHeight)
      rowFrame:SetWidth(contentWidth)
      rowFrame:Show()

      if headerConfig.sticky then
        rowFrame:SetParent(frame)
        rowFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        rowFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        rowFrame:SetFrameLevel(scrollArea.verticalScrollBar:GetFrameLevel() + 2)
      else
        rowFrame:SetParent(scrollArea.content)
        rowFrame:SetPoint("TOPLEFT", scrollArea.content, "TOPLEFT", 0, 0)
        rowFrame:SetFrameLevel(scrollArea.content:GetFrameLevel() + 1)
      end
      SetBackgroundColor(rowFrame, 0, 0, 0, 0.3)

      local offsetX = 0
      for columnIndex = 1, #columns do
        local columnConfig = columns[columnIndex]
        local columnWidth = columnConfig.width or defaultColumnWidth
        local columnTextAlign = columnConfig.align or "LEFT"
        local sortingEnabled = sortingConfig and sortingConfig.enabled
        local columnSortable = sortingEnabled and columnConfig.sorting and columnConfig.sorting.enabled

        local cellFrame = rowFrame.cells[columnIndex]
        if not cellFrame then
          cellFrame = createCell(rowFrame, "$parentCell" .. columnIndex, columnSortable == true)
          rowFrame.cells[columnIndex] = cellFrame
        end

        cellFrame.rowIndex = HEADER_ROW_INDEX
        cellFrame.columnIndex = columnIndex
        cellFrame.columnId = columnConfig.id

        cellFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        cellFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        cellFrame:SetWidth(columnWidth)
        cellFrame:SetHeight(headerHeight)
        cellFrame.label:SetJustifyH(columnTextAlign)
        cellFrame.label:SetPoint("TOPLEFT", cellFrame, "TOPLEFT", padding, -padding)
        cellFrame.label:SetPoint("BOTTOMRIGHT", cellFrame, "BOTTOMRIGHT", -padding, padding)
        cellFrame.label:SetText(columnConfig.headerText or "")
        applyBackgroundColor(cellFrame, nil)
        cellFrame:Show()

        if columnSortable then
          local state = frame.sortState
          local showSortHighlight = state.columnId == columnConfig.id and state.direction ~= nil
          if showSortHighlight then
            SetHighlightColor(cellFrame, 1, 1, 1, 0.03)
          else
            SetHighlightColor(cellFrame, 1, 1, 1, 0)
          end
        end

        offsetX = offsetX + columnWidth
      end

      for columnIndex = #columns + 1, #rowFrame.cells do
        local cellFrame = rowFrame.cells[columnIndex]
        if cellFrame then
          cellFrame:Hide()
        end
      end
    elseif frame.rows[HEADER_ROW_INDEX] then
      frame.rows[HEADER_ROW_INDEX]:Hide()
    end

    local bodyOffsetY = scrollContentHeight
    for rowIndex = 1, #data do
      local row = data[rowIndex]
      local rowHeight = row.height or defaultRowHeight

      local rowFrame = frame.rows[rowIndex]
      if not rowFrame then
        rowFrame = createRow(rowIndex)
      end

      rowFrame:SetParent(scrollArea.content)
      rowFrame:SetPoint("TOPLEFT", scrollArea.content, "TOPLEFT", 0, -bodyOffsetY)
      rowFrame:SetWidth(contentWidth)
      rowFrame:SetHeight(rowHeight)
      rowFrame:Show()

      if row.backgroundColor then
        applyBackgroundColor(rowFrame, row.backgroundColor)
      elseif rowStyle.striped and rowIndex % 2 == 1 then
        SetBackgroundColor(rowFrame, 1, 1, 1, 0.02)
      else
        applyBackgroundColor(rowFrame, nil)
      end

      local offsetX = 0
      for columnIndex = 1, #columns do
        local columnConfig = columns[columnIndex]
        local columnWidth = columnConfig.width or defaultColumnWidth
        local columnTextAlign = columnConfig.align or "LEFT"
        local cell = row.data[columnIndex]
        local displayText = tostring(cell and cell.data or "")
        if columnConfig.render and cell then
          displayText = tostring(columnConfig.render(cell, row, rowIndex) or "")
        end

        local cellFrame = rowFrame.cells[columnIndex]
        if not cellFrame then
          cellFrame = createCell(rowFrame, "$parentCell" .. columnIndex, false)
          rowFrame.cells[columnIndex] = cellFrame
        end

        cellFrame.rowIndex = rowIndex
        cellFrame.columnIndex = columnIndex
        cellFrame.columnId = columnConfig.id

        cellFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        cellFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        cellFrame:SetWidth(columnWidth)
        cellFrame:SetHeight(rowHeight)
        cellFrame.label:SetJustifyH(columnTextAlign)
        cellFrame.label:SetPoint("TOPLEFT", cellFrame, "TOPLEFT", padding, -padding)
        cellFrame.label:SetPoint("BOTTOMRIGHT", cellFrame, "BOTTOMRIGHT", -padding, padding)
        cellFrame.label:SetText(displayText)
        if cell and cell.backgroundColor then
          applyBackgroundColor(cellFrame, cell.backgroundColor)
        else
          applyBackgroundColor(cellFrame, nil)
        end
        cellFrame:Show()

        offsetX = offsetX + columnWidth
      end

      for columnIndex = #columns + 1, #rowFrame.cells do
        local cellFrame = rowFrame.cells[columnIndex]
        if cellFrame then
          cellFrame:Hide()
        end
      end

      bodyOffsetY = bodyOffsetY + rowHeight
      scrollContentHeight = scrollContentHeight + rowHeight
    end

    for rowIndex = #data + 1, #frame.rows do
      if not isHeaderRow(rowIndex) then
        local rowFrame = frame.rows[rowIndex]
        if rowFrame then
          rowFrame:Hide()
        end
      end
    end

    local shownHeight = scrollContentHeight
    if headerConfig.enabled and headerConfig.sticky then
      shownHeight = shownHeight + headerHeight
    end

    frame.layoutSize.shownWidth = contentWidth
    frame.layoutSize.shownHeight = shownHeight

    scrollArea:UpdateLayout(contentWidth, scrollContentHeight)
  end

  ---@param shouldSort boolean
  local function runTable(shouldSort)
    if shouldSort then
      validateSortState()
      applySort()
    end
    renderTable()
  end

  ---@param columnId string
  ---@param button string|nil
  function frame:OnHeaderColumnClick(columnId, button)
    if type(columnId) ~= "string" or columnId == "" then
      return
    end
    local state = self.sortState

    if button == "RightButton" then
      setSortStateToDefault()
      runTable(true)
      scrollToTopAfterHeaderSort()
      notifySortStateChanged()
      return
    end

    local sortingConfig = self.config.sorting
    if state.columnId == columnId then
      state.direction = (state.direction == "asc") and "desc" or "asc"
    else
      state.columnId = columnId
      state.direction = (sortingConfig and sortingConfig.defaultOrder == "asc") and "asc" or "desc"
    end
    runTable(true)
    scrollToTopAfterHeaderSort()
    notifySortStateChanged()
  end

  ---@param cellFrame LiqUI_TableCellFrame
  function frame:OnCellEnter(cellFrame)
    local config = self.config
    local rowIndex = cellFrame.rowIndex
    local columnIndex = cellFrame.columnIndex
    local columns = activeColumns(self)
    local columnConfig = columns[columnIndex]
    if not columnConfig then
      return
    end

    if isHeaderRow(rowIndex) then
      local sortingConfig = config.sorting
      local columnSortable = sortingConfig and sortingConfig.enabled
        and columnConfig.sorting and columnConfig.sorting.enabled
      if columnSortable then
        GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(columnConfig.headerText or "", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("<Click to Sort>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        GameTooltip:AddLine("<Right Click to Reset>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        GameTooltip:Show()
      end
      if columnConfig.onEnter then
        columnConfig.onEnter(cellFrame, columnIndex, columnConfig.id, columnConfig)
      end
      return
    end

    local row = self.data[rowIndex]
    if not row then
      return
    end
    local cell = row.data[columnIndex]

    if config.rowStyle.highlight then
      local rowFrame = self.rows[rowIndex]
      if rowFrame then
        SetHighlightColor(rowFrame, 1, 1, 1, 0.05)
      end
    end
    local cellStyle = config.cellStyle
    if cellStyle and cellStyle.highlight then
      SetHighlightColor(cellFrame, 1, 1, 1, 0.05)
    end
    if row.onEnter then
      row.onEnter(cellFrame)
    end
    if cell and cell.onEnter then
      cell.onEnter(cellFrame, rowIndex, columnIndex, cellFrame.columnId, row)
    end
  end

  ---@param cellFrame LiqUI_TableCellFrame
  function frame:OnCellLeave(cellFrame)
    local config = self.config
    local rowIndex = cellFrame.rowIndex
    local columnIndex = cellFrame.columnIndex
    local columns = activeColumns(self)
    local columnConfig = columns[columnIndex]
    if not columnConfig then
      return
    end

    if isHeaderRow(rowIndex) then
      local sortingConfig = config.sorting
      local columnSortable = sortingConfig and sortingConfig.enabled
        and columnConfig.sorting and columnConfig.sorting.enabled
      if columnSortable or columnConfig.onEnter then
        GameTooltip:Hide()
      end
      if columnConfig.onLeave then
        columnConfig.onLeave(cellFrame, columnIndex, columnConfig.id, columnConfig)
      end
      return
    end

    local row = self.data[rowIndex]
    if not row then
      return
    end
    local cell = row.data[columnIndex]

    if config.rowStyle.highlight then
      local rowFrame = self.rows[rowIndex]
      if rowFrame then
        SetHighlightColor(rowFrame, 1, 1, 1, 0)
      end
    end
    local cellStyle = config.cellStyle
    if cellStyle and cellStyle.highlight then
      SetHighlightColor(cellFrame, 1, 1, 1, 0)
    end
    if row.onLeave then
      row.onLeave(cellFrame)
    end
    if cell and cell.onLeave then
      cell.onLeave(cellFrame, rowIndex, columnIndex, cellFrame.columnId, row)
    end
  end

  ---@param cellFrame LiqUI_TableCellFrame
  ---@param button string
  function frame:OnCellClick(cellFrame, button)
    local rowIndex = cellFrame.rowIndex
    local columnIndex = cellFrame.columnIndex
    local columns = activeColumns(self)
    local columnConfig = columns[columnIndex]
    if not columnConfig then
      return
    end

    if isHeaderRow(rowIndex) then
      local sortingConfig = self.config.sorting
      local columnSortable = sortingConfig and sortingConfig.enabled
        and columnConfig.sorting and columnConfig.sorting.enabled
      if columnSortable and columnConfig.id then
        self:OnHeaderColumnClick(columnConfig.id, button)
      end
      return
    end

    local row = self.data[rowIndex]
    if not row then
      return
    end
    local cell = row.data[columnIndex]

    if row.onClick then
      row.onClick(cellFrame, button)
    end
    if cell and cell.onClick then
      cell.onClick(cellFrame, button, rowIndex, columnIndex, cellFrame.columnId, row)
    end
  end

  function frame:ScrollToTop()
    local scrollArea = self.scrollArea
    if not scrollArea then
      return
    end
    scrollArea:ScrollToTop()
  end

  ---@param data LiqUI_TableData
  function frame:SetData(data)
    local columns = self.config.columns
    if not columns or #columns == 0 then
      error("LiqUI Table: config.columns is required", 2)
    end
    if type(data) ~= "table" then
      error("LiqUI Table: data must be a table", 2)
    end
    for rowIndex = 1, #data do
      if type(data[rowIndex]) ~= "table" then
        error(format("LiqUI Table: row #%d must be a table", rowIndex), 2)
      end
    end
    validateSortingColumns(columns, self.config.sorting)
    self.data = normalizeData(data)
    runTable(true)
  end

  ---@param columns LiqUI_TableConfigColumn[]
  function frame:SetColumns(columns)
    if not columns or #columns == 0 then
      error("LiqUI Table: columns is required", 2)
    end
    validateSortingColumns(columns, self.config.sorting)
    self.config.columns = columns
    runTable(true)
  end

  ---@param columnId string
  ---@param hidden boolean
  function frame:SetColumnHidden(columnId, hidden)
    if not self.db then
      return
    end
    self.db.hiddenColumns = self.db.hiddenColumns or {}
    if hidden then
      self.db.hiddenColumns[columnId] = true
    else
      self.db.hiddenColumns[columnId] = nil
    end
    runTable(true)
  end

  ---@return LiqUI_TableSortState
  function frame:GetSortState()
    local state = self.sortState
    return { columnId = state.columnId, direction = state.direction }
  end

  ---@param columnId string|nil
  ---@param direction "asc"|"desc"|nil
  function frame:SetSortState(columnId, direction)
    local state = self.sortState
    state.columnId = columnId
    state.direction = direction
    runTable(true)
    notifySortStateChanged()
  end

  ---@param height number
  function frame:SetRowHeight(height)
    self.config.rowStyle.height = height
    if self.scrollArea then
      self.scrollArea:SetWheelPanExtent(height)
    end
    runTable(false)
  end

  ---@return number width
  ---@return number height
  function frame:GetSize()
    local layoutSize = self.layoutSize
    return layoutSize.shownWidth, layoutSize.shownHeight
  end

  frame.scrollArea:HookScript("OnSizeChanged", function()
    renderTable()
  end)

  runTable(false)
  table.insert(self.frames, frame)
  return frame
end
