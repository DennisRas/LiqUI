local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_TableManager
local Table = {}
LiqUI.Table = Table

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
    rows = {
      height = LiqUI.Constants.layout.sizes.row,
      highlight = true,
      striped = true,
    },
    columns = {
      width = LiqUI.Constants.layout.sizes.column,
      highlight = false,
      striped = false,
    },
    cells = {
      padding = LiqUI.Constants.layout.sizes.padding,
      highlight = false,
      fontObject = "GameFontHighlight",
    },
    sorting = {
      enabled = false,
      defaultOrder = "desc",
      defaultCompare = function(_, _)
        return false
      end,
    },
    data = {
      columns = {},
      rows = {},
    },
  }
  ---@type LiqUI_TableConfig
  local mergedConfig = {}
  LiqUI.Utils:TableMergeConfig(mergedConfig, defaultConfig)
  LiqUI.Utils:TableMergeConfig(mergedConfig, config or {})
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
  frame.rows = {}
  frame.data = frame.config.data
  ---@type LiqUI_TableSortState
  frame.sortState = {columnId = nil, direction = nil}
  frame.db = db
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

  ---@param columnId string|nil
  ---@return number|nil
  function frame:ColumnIndexForId(columnId)
    if not columnId or not self.data or not self.data.columns then
      return nil
    end
    for columnIndex, column in ipairs(self.data.columns) do
      if column.id == columnId then
        return columnIndex
      end
    end
    return nil
  end

  function frame:SetSortStateToDefault()
    local state = self.sortState
    state.columnId = nil
    state.direction = nil
  end

  function frame:ValidateSortState()
    local sorting = self.config.sorting
    if not sorting or not sorting.enabled then
      return
    end
    local state = self.sortState
    if not state then
      return
    end
    if state.columnId and not self:ColumnIndexForId(state.columnId) then
      self:SetSortStateToDefault()
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
      frame:SetSortStateToDefault()
    end
  end

  local function notifySortStateChanged()
    local sorting = frame.config.sorting
    if sorting and sorting.onStateChanged then
      sorting.onStateChanged(frame.sortState)
    end
  end

  frame.scrollFrame = LiqUI.Utils:CreateScrollArea(frame, {
    name = "$parentScrollArea",
    vertical = true,
    horizontal = false,
    wheelPanExtent = frame.config.rows.height,
  })

  function frame:ScrollToTop()
    local scrollFrame = self.scrollFrame
    if not scrollFrame then
      return
    end
    scrollFrame:ScrollToTop()
  end

  local function scrollToTopAfterHeaderSort()
    C_Timer.After(0, function()
      frame:ScrollToTop()
    end)
  end

  function frame:ApplySortToData()
    local sorting = self.config.sorting
    if not sorting or not sorting.enabled then
      return
    end

    local rows = self.data.rows
    if not rows or #rows <= 1 then
      return
    end

    local headerEnabled = self.config.header.enabled
    local dataStart = headerEnabled and 2 or 1
    if not rows[dataStart] then
      return
    end

    local state = self.sortState
    local sortColumnIndex = self:ColumnIndexForId(state.columnId)
    if state.columnId and state.direction and not sortColumnIndex then
      return
    end

    ---@type LiqUI_TableDataRow[]
    local dataRows = {}
    for rowIndex = dataStart, #rows do
      dataRows[#dataRows + 1] = rows[rowIndex]
    end

    local columnSort = state.columnId and state.direction and sortColumnIndex
    if not columnSort then
      table.sort(dataRows, sorting.defaultCompare)
      for rowIndex = 1, #dataRows do
        rows[dataStart + rowIndex - 1] = dataRows[rowIndex]
      end
      return
    end

    local ascending = state.direction == "asc"
    local columnConfig = self.data.columns[sortColumnIndex]
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
    table.sort(dataRows, function(rowA, rowB)
      if ascending then
        return compare(rowA, rowB)
      end
      return compare(rowB, rowA)
    end)

    for rowIndex = 1, #dataRows do
      rows[dataStart + rowIndex - 1] = dataRows[rowIndex]
    end
  end

  ---@param columnId string
  ---@param button string|nil
  function frame:OnHeaderColumnClick(columnId, button)
    if type(columnId) ~= "string" or columnId == "" then
      return
    end
    local state = self.sortState
    if not state then
      state = {columnId = nil, direction = nil}
      self.sortState = state
    end

    if button == "RightButton" then
      self:SetSortStateToDefault()
      self:ApplySortToData()
      self:RenderTable()
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
    self:ApplySortToData()
    self:RenderTable()
    scrollToTopAfterHeaderSort()
    notifySortStateChanged()
  end

  ---Set the table data
  ---@param data LiqUI_TableData
  function frame:SetData(data)
    self.data = data
    if data and data.columns and self.config.sorting and self.config.sorting.enabled then
      for columnIndex, column in ipairs(data.columns) do
        if not column.sorting then
          error(format('LiqUI Table: column #%d ("%s") must define sorting', columnIndex, tostring(column.id)), 2)
        end
      end
    end
    self:ValidateSortState()
    self:ApplySortToData()
    self:RenderTable()
  end

  ---Set the row height
  ---@param height number
  function frame:SetRowHeight(height)
    self.config.rows.height = height
    if self.scrollFrame then
      self.scrollFrame:SetWheelPanExtent(height)
    end
    self:RenderTable()
  end

  ---Width and total height after the last RenderTable (includes sticky header when enabled).
  ---@return number width
  ---@return number height
  function frame:GetSize()
    local width = self.contentWidth or 0
    local height = self.contentHeight or 0
    if self.config.header.enabled and self.config.header.sticky then
      height = height + (self.config.header.height or 30)
    end
    return width, height
  end

  function frame:RenderTable()
    local offsetY = 0
    local offsetX = 0

    LiqUI.Utils:TableForEach(frame.rows, function(rowFrame) rowFrame:Hide() end)
    LiqUI.Utils:TableForEach(frame.data.rows, function(row, rowIndex)
      local rowFrame = frame.rows[rowIndex]
      local rowHeight = frame.config.rows.height
      local isStickyRow = false
      local isHeaderRow = rowIndex == 1 and frame.config.header.enabled

      if not rowFrame then
        rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, frame)
        rowFrame.columns = {}
        frame.rows[rowIndex] = rowFrame
        LiqUI.Utils:BindScrollBoxMouseWheel(rowFrame, frame.scrollFrame:GetWheelScrollBox())
      end

      if rowIndex == 1 then
        if frame.config.header.enabled then
          rowHeight = frame.config.header.height
        end
        if frame.config.header.sticky then
          isStickyRow = true
        end
      end

      -- Sticky header
      if isStickyRow then
        rowFrame:SetParent(frame)
        rowFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        rowFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        rowFrame:SetFrameLevel(frame.scrollFrame.verticalScrollBar:GetFrameLevel() + 2)
        if not row.backgroundColor then
          LiqUI.Utils:SetBackgroundColor(rowFrame, 0, 0, 0, 0.3)
        end
      else
        rowFrame:SetParent(frame.scrollFrame.content)
        rowFrame:SetPoint("TOPLEFT", frame.scrollFrame.content, "TOPLEFT", 0, -offsetY)
        rowFrame:SetWidth(offsetX)
        if frame.config.rows.striped and rowIndex % 2 == 1 then
          LiqUI.Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
        end
      end

      if row.backgroundColor then
        LiqUI.Utils:SetBackgroundColor(rowFrame, row.backgroundColor.r, row.backgroundColor.g, row.backgroundColor.b, row.backgroundColor.a)
      end

      rowFrame.data = row
      rowFrame:SetHeight(rowHeight)
      rowFrame:SetScript("OnEnter", function() rowFrame:onEnterHandler(rowFrame) end)
      rowFrame:SetScript("OnLeave", function() rowFrame:onLeaveHandler(rowFrame) end)
      rowFrame:SetScript("OnClick", function(_, button)
        rowFrame:onClickHandler(rowFrame, button)
      end)
      rowFrame:Show()

      function rowFrame:onEnterHandler(f)
        if rowIndex > 1 or not frame.config.header.enabled then
          LiqUI.Utils:SetHighlightColor(rowFrame, 1, 1, 1, .05)
        end
        if row.onEnter then
          row:onEnter(f)
        end
      end

      function rowFrame:onLeaveHandler(f)
        if rowIndex > 1 or not frame.config.header.enabled then
          LiqUI.Utils:SetHighlightColor(rowFrame, 1, 1, 1, 0)
        end
        if row.onLeave then
          row:onLeave(f)
        end
      end

      function rowFrame:onClickHandler(f, button)
        if row.onClick then
          row:onClick(f, button)
        end
      end

      offsetX = 0
      LiqUI.Utils:TableForEach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
      LiqUI.Utils:TableForEach(row.columns, function(column, columnIndex)
        local columnFrame = rowFrame.columns[columnIndex]
        local columnConfig = frame.data.columns[columnIndex]
        local sortingConfig = frame.config.sorting
        local sortingEnabled = isHeaderRow and sortingConfig and sortingConfig.enabled
        local columnSortable = sortingEnabled and columnConfig and columnConfig.sorting and columnConfig.sorting.enabled
        local columnWidth = columnConfig and columnConfig.width or frame.config.columns.width
        local columnTextAlign = columnConfig and columnConfig.align or "LEFT"

        if not columnFrame then
          columnFrame = CreateFrame("Button", "$parentCol" .. columnIndex, rowFrame)
          columnFrame.text = columnFrame:CreateFontString("$parentText", "OVERLAY")
          columnFrame.text:SetFontObject(frame.config.cells.fontObject or "GameFontHighlight")
          rowFrame.columns[columnIndex] = columnFrame
          LiqUI.Utils:BindScrollBoxMouseWheel(columnFrame, frame.scrollFrame:GetWheelScrollBox())
        end

        columnFrame.data = column
        columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        columnFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        columnFrame:SetWidth(columnWidth)
        columnFrame:SetScript("OnEnter", function() columnFrame:onEnterHandler(columnFrame) end)
        columnFrame:SetScript("OnLeave", function() columnFrame:onLeaveHandler(columnFrame) end)
        columnFrame:SetScript("OnClick", function(_, button)
          columnFrame:onClickHandler(columnFrame, button)
        end)
        if sortingEnabled then
          columnFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end
        columnFrame.text:SetWordWrap(false)
        columnFrame.text:SetJustifyH(columnTextAlign)
        columnFrame.text:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", frame.config.cells.padding, -frame.config.cells.padding)
        columnFrame.text:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -frame.config.cells.padding, frame.config.cells.padding)
        columnFrame.text:SetText(column.text)
        columnFrame:Show()

        if column.backgroundColor then
          LiqUI.Utils:SetBackgroundColor(columnFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
        else
          LiqUI.Utils:SetBackgroundColor(columnFrame, 0, 0, 0, 0)
        end

        if sortingEnabled then
          local state = frame.sortState
          local showSortHighlight = columnSortable
            and state
            and state.columnId == columnConfig.id
            and state.direction ~= nil
          if showSortHighlight then
            LiqUI.Utils:SetHighlightColor(columnFrame, 1, 1, 1, 0.03)
          else
            LiqUI.Utils:SetHighlightColor(columnFrame, 1, 1, 1, 0)
          end
        end

        function columnFrame:onEnterHandler(f)
          rowFrame:onEnterHandler(f)
          if column.onEnter then
            column.onEnter(f)
          end
          if columnSortable then
            if not column.onEnter then
              GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
              GameTooltip:SetText(columnConfig.headerText or column.text or "", 1, 1, 1)
            else
              GameTooltip:AddLine(" ")
            end
            GameTooltip:AddLine("<Click to Sort>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:AddLine("<Right Click to Reset>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
          end
        end

        function columnFrame:onLeaveHandler(f)
          rowFrame:onLeaveHandler(f)
          if column.onLeave then
            column.onLeave(f)
          end
          if columnSortable and not column.onLeave then
            GameTooltip:Hide()
          elseif column.onEnter then
            GameTooltip:Hide()
          end
        end

        function columnFrame:onClickHandler(f, button)
          if columnSortable and columnConfig.id then
            frame:OnHeaderColumnClick(columnConfig.id, button)
            return
          end
          rowFrame:onClickHandler(f, button)
          if column.onClick then
            column:onClick(f, button)
          end
        end

        offsetX = offsetX + columnWidth
      end)

      if not isStickyRow then
        offsetY = offsetY + rowHeight
      end
    end)

    frame.scrollFrame:SetParent(frame)
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, frame.config.header.sticky and -frame.config.header.height or 0)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.scrollFrame:UpdateLayout(offsetX, offsetY)
    frame.contentWidth = offsetX
    frame.contentHeight = offsetY
  end

  frame.scrollFrame:HookScript("OnSizeChanged", function() frame:RenderTable() end)
  frame:RenderTable()
  table.insert(self.frames, frame)
  return frame
end
