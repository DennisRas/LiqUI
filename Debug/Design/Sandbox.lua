---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design
local layout = Design.layout
local Events = LiqUI.Events
local MixFrames = Mixin
local CreateScrollBox = LiqUI.Utils.CreateScrollBox
local BindScrollBoxMouseWheel = LiqUI.Utils.BindScrollBoxMouseWheel
local SetPixelPoint = PixelUtil.SetPoint
local SetPixelSize = PixelUtil.SetSize
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
local WINDOW_SAMPLE_HEIGHT = 168
local PANEL_SCROLL_HEIGHT = 160
---@type LiqUI_DesignBorder
local SURFACE_BORDER = {size = 1, color = "shade60"}
---@type number[]
local TABLE_COLUMNS = {42, 33, 25}
local TABLE_SAMPLE_ROWS = {
  {"Liquidor", "Tank", "2840"},
  {"Calia", "Healer", "2715"},
  {"Toren", "DPS", "3120"},
  {"Mara", "DPS", "3055"},
}
local TINT_KEYS = {"tint5", "tint10", "tint15", "tint20", "tint25", "tint30", "tint35", "tint40", "tint45", "tint50"}
local SHADE_KEYS_NEAR = {"shade5", "shade10", "shade15", "shade20", "shade25", "shade30", "shade35", "shade40", "shade45", "shade50"}
local SHADE_KEYS_FAR = {"shade55", "shade60", "shade65", "shade70", "shade75", "shade80", "shade85", "shade90", "shade95"}
local FIXED_KEYS = {"white", "grey", "black"}
local LOREM_PARAGRAPH =
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
local LOREM_PARAGRAPH_TWO =
  "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem."
local LOREM_BLOCK = LOREM_PARAGRAPH .. " " .. LOREM_PARAGRAPH_TWO .. " " .. LOREM_PARAGRAPH .. " " .. LOREM_PARAGRAPH_TWO

---@type LiqUI_DesignSandbox?
local sandbox
---@type LiqUI_DesignColorBinding[]
local colorBindings = {}
---@type LiqUI_DesignTypeSample[]
local typeSamples = {}
---@type LiqUI_ScrollBox[]
local panelScrollBoxes = {}

---@param color ColorMixin
---@return number, number, number, number
local function colorRGBA(color)
  return color:GetRGBA()
end

---@param frame LiqUI_DesignSandboxElement
---@param tokens LiqUI_DesignElement
local function setupElement(frame, tokens)
  MixFrames(frame, Design.Mixin)
  frame:Setup(tokens)
end

---@param parent Frame
---@param typeId LiqUI_DesignTypeId
---@return FontString
local function createTypeString(parent, typeId)
  local fontString = parent:CreateFontString(nil, "OVERLAY")
  ---@type LiqUI_DesignTypeSample
  local sample = {fontString = fontString, typeId = typeId}
  table.insert(typeSamples, sample)
  Design:ApplyType(fontString, typeId)
  return fontString
end

---@param parent Frame
---@param color ColorMixin
---@param labelText string
---@param onClick function?
---@return Frame, FontString
local function createSwatch(parent, color, labelText, onClick)
  local swatch = CreateFrame("Button", nil, parent)
  SetPixelSize(swatch, layout.swatchSize, layout.swatchSize)
  local fill = swatch:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints()
  fill:SetColorTexture(colorRGBA(color))
  ---@type LiqUI_DesignColorBinding
  local binding = {texture = fill, color = color}
  table.insert(colorBindings, binding)

  local label = createTypeString(parent, "label")
  SetPixelPoint(label, "TOP", swatch, "BOTTOM", 0, -2)
  label:SetText(labelText)

  if onClick then
    swatch:SetScript("OnClick", onClick)
  end
  return swatch, label
end

---@param button Button
---@param text string
local function setButtonLabel(button, text)
  local label = button:GetFontString()
  if not label then
    label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button:SetFontString(label)
  end
  Design:ApplyType(label, "label")
  local fontObject = Design.typography.label.fontObject
  button:SetNormalFontObject(fontObject)
  button:SetHighlightFontObject(fontObject)
  button:SetText(text)
end

---@param parent Frame
---@param tokens LiqUI_DesignElement
---@param text string
---@param options LiqUI_DesignSizeOptions?
---@return LiqUI_DesignSandboxElement
local function createSampleButton(parent, tokens, text, options)
  options = options or {}
  ---@class LiqUI_DesignSandboxElement
  local button = CreateFrame("Button", nil, parent)
  setButtonLabel(button, text)
  setupElement(button, tokens)
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {
    width = options.width or tokens.width,
    height = options.height or tokens.height,
  }
  Design:ApplySize(button, sizeOptions)
  return button
end

---@param parent Frame
---@param text string
---@return LiqUI_DesignSandboxElement
local function createTitlebarButton(parent, text)
  local tokens = Design.window.titlebar.button
  ---@class LiqUI_DesignSandboxElement
  local button = CreateFrame("Button", nil, parent)
  setButtonLabel(button, text)
  setupElement(button, tokens)
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {width = tokens.width, height = tokens.height}
  Design:ApplySize(button, sizeOptions)
  return button
end

---@param parent Frame
---@param text string
---@param enabled boolean?
---@param placeholder string?
---@return LiqUI_DesignSandboxElement
local function createSampleInput(parent, text, enabled, placeholder)
  ---@class LiqUI_DesignSandboxElement
  local input = CreateFrame("EditBox", nil, parent)
  input:SetAutoFocus(false)
  local labelStyle = Design.typography.label
  local tokens = Design.input
  input:SetFont(Design.fontFile, labelStyle.size, labelStyle.flags or Design.fontFlags)
  input:SetTextInsets(tokens.textInsets, tokens.textInsets, 0, 0)
  input:SetText(text or "")
  setupElement(input, tokens)
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {width = "50%", height = tokens.height}
  Design:SetPadding(parent, Design.window.body.padding)
  Design:ApplySize(input, sizeOptions)
  if placeholder then
    local instructions = input:CreateFontString(nil, "OVERLAY")
    Design:ApplyType(instructions, "label")
    instructions:SetJustifyH("LEFT")
    SetPixelPoint(instructions, "TOPLEFT", input, "TOPLEFT", tokens.textInsets, 0)
    SetPixelPoint(instructions, "BOTTOMRIGHT", input, "BOTTOMRIGHT", -tokens.textInsets, 0)
    instructions:SetText(placeholder)
    input.Instructions = instructions
  end
  input:SetScript("OnEditFocusGained", function(self)
    self.focused = true
    self:Apply()
  end)
  input:SetScript("OnEditFocusLost", function(self)
    self.focused = false
    self:Apply()
  end)
  input:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  input:SetScript("OnTextChanged", function(self)
    self:Apply()
  end)
  if enabled == false then
    input:Disable()
  end
  return input
end

---@param parent Frame
---@param title string
---@param options LiqUI_DesignSandboxWindowOptions?
---@return LiqUI_DesignSandboxWindowSample
local function createSampleWindow(parent, title, options)
  options = options or {}
  ---@type LiqUI_DesignElement
  local windowTokens = {background = Design.window.background}
  ---@class LiqUI_DesignSandboxElement
  local frame = CreateFrame("Frame", nil, parent)
  setupElement(frame, windowTokens)
  ---@type LiqUI_DesignSizeOptions
  local windowSize = {width = "100%", height = WINDOW_SAMPLE_HEIGHT}
  Design:ApplySize(frame, windowSize)

  ---@class LiqUI_DesignSandboxElement
  local titlebar = CreateFrame("Frame", nil, frame)
  setupElement(titlebar, Design.window.titlebar)
  SetPixelPoint(titlebar, "TOPLEFT", frame, "TOPLEFT", 0, 0)
  SetPixelPoint(titlebar, "TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  SetPixelHeight(titlebar, Design.window.titlebar.height)

  local titleText = createTypeString(titlebar, "title")
  SetPixelPoint(titleText, "LEFT", titlebar, "LEFT", 12, 0)
  titleText:SetText(title)

  local closeButton = createTitlebarButton(titlebar, "X")
  SetPixelPoint(closeButton, "RIGHT", titlebar, "RIGHT", 0, 0)

  ---@type LiqUI_DesignElement
  local bodyTokens = Design.window.body
  if options.bodyBackground then
    bodyTokens = {
      padding = Design.window.body.padding,
      background = {normal = options.bodyBackground},
    }
  end
  ---@class LiqUI_DesignSandboxElement
  local body = CreateFrame("Frame", nil, frame)
  setupElement(body, bodyTokens)
  SetPixelPoint(body, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  SetPixelPoint(body, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

  local bodyCopy = createTypeString(body, "p")
  SetPixelPoint(bodyCopy, "TOPLEFT", body, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)
  bodyCopy:SetJustifyH("LEFT")
  ---@type LiqUI_DesignSizeOptions
  local bodyCopySize = {width = "100%"}
  Design:ApplySize(bodyCopy, bodyCopySize)
  bodyCopy:SetText("Body copy sits in the content pane. The titlebar stays above it.")

  local overlay
  if options.showOverlay then
    ---@type LiqUI_DesignElement
    local overlayTokens = {
      background = Design.window.overlay.background,
      alpha = options.overlayAlpha or Design.window.overlay.alpha or 1,
    }
    ---@class LiqUI_DesignSandboxElement
    overlay = CreateFrame("Frame", nil, body)
    overlay:EnableMouse(true)
    overlay:SetFrameLevel(body:GetFrameLevel() + 10)
    setupElement(overlay, overlayTokens)
    overlay:SetAllPoints()
    local overlayText = createTypeString(overlay, "h3")
    SetPixelPoint(overlayText, "CENTER", overlay, "CENTER", 0, 0)
    overlayText:SetText("Loading characters...")
  end

  ---@type LiqUI_DesignSandboxWindowSample
  local sample = {
    frame = frame,
    titlebar = titlebar,
    body = body,
    overlay = overlay,
  }
  return sample
end

---@param parent Frame
---@param yOffset number
---@param heading string
---@param options LiqUI_DesignSandboxWindowOptions?
---@return number
local function addWindowSample(parent, yOffset, heading, options)
  local label = createTypeString(parent, "h3")
  SetPixelPoint(label, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, yOffset)
  label:SetText(heading)
  local windowY = yOffset - label:GetStringHeight() - layout.gap
  local sample = createSampleWindow(parent, "Weekly vault", options)
  SetPixelPoint(sample.frame, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, windowY)
  return windowY - WINDOW_SAMPLE_HEIGHT - layout.sectionGap
end

---@param options LiqUI_DesignSandboxPanelOptions
---@return LiqUI_DesignElement
local function panelShellTokens(options)
  local defaults = Design.panel
  local padding = options.padding
  if padding == nil then
    padding = defaults.padding
  end
  ---@type LiqUI_DesignElement
  local tokens = {padding = padding}
  if options.showBackground then
    tokens.background = {normal = options.background or defaults.background.normal}
    if options.showBorder then
      tokens.border = {
        size = SURFACE_BORDER.size,
        color = options.borderColor or SURFACE_BORDER.color,
      }
    end
  end
  return tokens
end

---@param parent Frame
---@param options LiqUI_DesignSandboxPanelOptions
---@return LiqUI_DesignSandboxPanelSample
local function createSamplePanel(parent, options)
  options = options or {}
  local defaults = Design.panel
  local tokens = panelShellTokens(options)
  ---@class LiqUI_DesignSandboxElement
  local frame = CreateFrame("Frame", nil, parent)
  setupElement(frame, tokens)
  Design:ApplySize(frame, {width = "100%"})

  local inset = 0
  if tokens.border then
    inset = tokens.border.size
  end
  local header
  local headerHeight = 0
  if options.title then
    ---@type LiqUI_DesignElement
    local headerTokens = {
      text = defaults.header.text,
    }
    if options.showHeaderBackground ~= false then
      headerTokens.background = {
        normal = options.headerBackground or defaults.header.background.normal,
      }
    end
    ---@class LiqUI_DesignSandboxElement
    header = CreateFrame("Frame", nil, frame)
    setupElement(header, headerTokens)
    SetPixelPoint(header, "TOPLEFT", frame, "TOPLEFT", inset, -inset)
    SetPixelPoint(header, "TOPRIGHT", frame, "TOPRIGHT", -inset, -inset)
    SetPixelHeight(header, defaults.header.height)
    headerHeight = defaults.header.height
    local title = createTypeString(header, "title")
    SetPixelPoint(title, "LEFT", header, "LEFT", defaults.header.padding, 0)
    title:SetText(options.title)
  end

  local body = CreateFrame("Frame", nil, frame)
  if header then
    SetPixelPoint(body, "TOPLEFT", header, "BOTTOMLEFT", 0, 0)
  else
    SetPixelPoint(body, "TOPLEFT", frame, "TOPLEFT", inset, -inset)
  end
  SetPixelPoint(body, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, inset)

  local padding = tokens.padding or 0
  local text = options.text or "Panel body copy."
  local scrollBox
  if options.maxHeight then
    SetPixelHeight(frame, options.maxHeight)
    ---@type LiqUI_ScrollBoxOptions
    local scrollOptions = {barWidth = layout.scrollBar}
    scrollBox = CreateScrollBox(body, nil, scrollOptions)
    SetPixelPoint(scrollBox, "TOPLEFT", body, "TOPLEFT", 0, 0)
    SetPixelPoint(scrollBox, "BOTTOMRIGHT", body, "BOTTOMRIGHT", -layout.scrollBar, 0)
    BindScrollBoxMouseWheel(frame, scrollBox)
    local scrollChild = scrollBox.scrollChild
    Design:SetPadding(scrollChild, padding)
    ---@type LiqUI_DesignStackOptions
    local textStack = {
      padding = padding,
      gap = 8,
      onLayout = function()
        scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
      end,
    }
    local copies = {text, LOREM_PARAGRAPH, LOREM_PARAGRAPH_TWO}
    for index = 1, #copies do
      local fontString = createTypeString(scrollChild, "p")
      fontString:SetJustifyH("LEFT")
      ---@type LiqUI_DesignSizeOptions
      local copySize = {width = "100%"}
      Design:ApplySize(fontString, copySize)
      Design:Stack(scrollChild, fontString, textStack)
      fontString:SetText(copies[index])
    end
    Design:RequestStackLayout(scrollChild)
    table.insert(panelScrollBoxes, scrollBox)
  else
    Design:SetPadding(body, padding)
    local bodyCopy = createTypeString(body, "p")
    bodyCopy:SetJustifyH("LEFT")
    bodyCopy:SetText(text)
    ---@type LiqUI_DesignSizeOptions
    local bodyCopySize = {width = "100%"}
    Design:ApplySize(bodyCopy, bodyCopySize)
    SetPixelPoint(bodyCopy, "TOPLEFT", body, "TOPLEFT", padding, -padding)
    local sizing = false
    local function sizeToContent()
      if sizing then
        return
      end
      sizing = true
      local textHeight = math.max(1, bodyCopy:GetStringHeight())
      local height = headerHeight + padding * 2 + textHeight + inset * 2
      SetPixelHeight(frame, height)
      sizing = false
    end
    frame:HookScript("OnSizeChanged", sizeToContent)
    sizeToContent()
  end

  ---@type LiqUI_DesignSandboxPanelSample
  local sample = {
    frame = frame,
    header = header,
    body = body,
    scrollBox = scrollBox,
  }
  return sample
end

---@param parent Frame
---@param heading string
---@param options LiqUI_DesignSandboxPanelOptions
---@param stackOptions LiqUI_DesignStackOptions
local function addPanelSample(parent, heading, options, stackOptions)
  local wrap = CreateFrame("Frame", nil, parent)
  Design:ApplySize(wrap, {width = "100%"})
  local label = createTypeString(wrap, "h3")
  label:SetText(heading)
  SetPixelPoint(label, "TOPLEFT", wrap, "TOPLEFT", 0, 0)
  local sample = createSamplePanel(wrap, options)
  SetPixelPoint(sample.frame, "TOPLEFT", label, "BOTTOMLEFT", 0, -layout.gap)
  local function sizeWrap()
    local height = label:GetStringHeight() + layout.gap + sample.frame:GetHeight()
    SetPixelHeight(wrap, math.max(1, height))
    Design:RequestStackLayout(parent)
  end
  sample.frame:HookScript("OnSizeChanged", sizeWrap)
  sizeWrap()
  Design:Stack(parent, wrap, stackOptions)
end

---@param parent Frame
---@param tokens LiqUI_DesignElement
---@param texts string[]
---@param yOffset number
---@param options LiqUI_DesignTableRowOptions
---@return LiqUI_DesignSandboxElement, number
local function createTableRow(parent, tokens, texts, yOffset, options)
  options = options or {}
  ---@class LiqUI_DesignSandboxElement
  local row = CreateFrame("Button", nil, parent)
  local inset = options.inset or 0
  SetPixelPoint(row, "TOPLEFT", parent, "TOPLEFT", inset, yOffset)
  row.allowHighlight = options.highlight
  row.alt = options.alt
  setupElement(row, tokens)
  row:EnableMouse(options.highlight and true or false)
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {width = "100%", height = Design.table.rowHeight}
  Design:ApplySize(row, sizeOptions)
  ---@type FontString[]
  local cells = {}
  row.cells = cells
  local cellPadding = Design.table.cellPadding
  for index = 1, #TABLE_COLUMNS do
    local cell = createTypeString(row, "label")
    cell:SetJustifyH("LEFT")
    cell:SetText(texts[index])
    cells[index] = cell
  end
  local function layoutCells()
    local rowWidth = row:GetWidth()
    local columnOffset = 0
    for index = 1, #TABLE_COLUMNS do
      local width = rowWidth * TABLE_COLUMNS[index] / 100
      local cell = cells[index]
      SetPixelPoint(cell, "LEFT", row, "LEFT", columnOffset + cellPadding, 0)
      SetPixelWidth(cell, math.max(1, width - cellPadding * 2))
      columnOffset = columnOffset + width
    end
  end
  row:HookScript("OnSizeChanged", layoutCells)
  layoutCells()
  return row, yOffset - Design.table.rowHeight
end

---@param tableOptions LiqUI_DesignTableOptions
---@param isHeader boolean
---@param inset number
---@param alt boolean?
---@return LiqUI_DesignTableRowOptions
local function tableRowOptions(tableOptions, isHeader, inset, alt)
  local highlight = tableOptions.highlightRows
  if highlight == nil then
    highlight = Design.table.highlightRows
  end
  if isHeader then
    highlight = tableOptions.highlightHeader
    if highlight == nil then
      highlight = Design.table.highlightHeader
    end
  end
  ---@type LiqUI_DesignTableRowOptions
  local rowOptions = {highlight = highlight and true or false, inset = inset, alt = alt}
  return rowOptions
end

---@param parent Frame
---@param yOffset number
---@param options LiqUI_DesignTableOptions
---@return LiqUI_DesignSandboxElement, number, number
local function createTableShell(parent, yOffset, options)
  ---@type LiqUI_DesignElement
  local tokens = {background = Design.table.background}
  if options.showBorder then
    tokens.border = SURFACE_BORDER
  end
  ---@class LiqUI_DesignSandboxElement
  local frame = CreateFrame("Frame", nil, parent)
  setupElement(frame, tokens)
  SetPixelPoint(frame, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, yOffset)
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {width = "100%"}
  Design:ApplySize(frame, sizeOptions)
  local inset = 0
  if options.showBorder then
    inset = SURFACE_BORDER.size
    Design:SetPadding(frame, inset)
  end
  return frame, -inset, inset
end

---@param frame Frame
---@param pageY number
---@param innerY number
---@param inset number
---@return number
local function closeTableShell(frame, pageY, innerY, inset)
  local height = -innerY + inset
  SetPixelHeight(frame, math.max(1, height))
  return pageY - height
end

---@param parent Frame
---@param yOffset number
---@param title string
---@param options LiqUI_DesignTableOptions
---@return number
local function addTableSample(parent, yOffset, title, options)
  local label = createTypeString(parent, "h3")
  SetPixelPoint(label, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, yOffset)
  label:SetText(title)
  local tableY = yOffset - label:GetStringHeight() - layout.gap
  local shell, innerY, inset = createTableShell(parent, tableY, options)
  _, innerY = createTableRow(
    shell,
    Design.table.header,
    {"Character", "Role", "Score"},
    innerY,
    tableRowOptions(options, true, inset)
  )
  for index = 1, #TABLE_SAMPLE_ROWS do
    local alt
    if options.stripes then
      alt = index % 2 == 1
    end
    _, innerY = createTableRow(
      shell,
      Design.table.row,
      TABLE_SAMPLE_ROWS[index],
      innerY,
      tableRowOptions(options, false, inset, alt)
    )
  end
  return closeTableShell(shell, tableY, innerY, inset) - layout.sectionGap
end

---@param pageId LiqUI_DesignSandboxPageId
local function selectPage(pageId)
  if not sandbox then
    return
  end
  sandbox.menu.colorsRow.selected = pageId == "colors"
  sandbox.menu.windowRow.selected = pageId == "window"
  sandbox.menu.panelRow.selected = pageId == "panel"
  sandbox.menu.tableRow.selected = pageId == "table"
  sandbox.menu.buttonsRow.selected = pageId == "buttons"
  sandbox.menu.inputRow.selected = pageId == "input"
  sandbox.menu.textRow.selected = pageId == "text"
  sandbox.body.colorsPage:SetShown(pageId == "colors")
  sandbox.body.windowPage:SetShown(pageId == "window")
  sandbox.body.panelPage:SetShown(pageId == "panel")
  sandbox.body.tablePage:SetShown(pageId == "table")
  sandbox.body.buttonsPage:SetShown(pageId == "buttons")
  sandbox.body.inputPage:SetShown(pageId == "input")
  sandbox.body.textPage:SetShown(pageId == "text")
  sandbox.menu.colorsRow:Apply()
  sandbox.menu.windowRow:Apply()
  sandbox.menu.panelRow:Apply()
  sandbox.menu.tableRow:Apply()
  sandbox.menu.buttonsRow:Apply()
  sandbox.menu.inputRow:Apply()
  sandbox.menu.textRow:Apply()
  Design:LayoutStacks()
end

---@param parent Frame
---@param text string
---@param pageId LiqUI_DesignSandboxPageId
---@param yOffset number
---@return LiqUI_DesignSandboxElement
local function createMenuRow(parent, text, pageId, yOffset)
  local tokens = Design.window.menu.row
  ---@class LiqUI_DesignSandboxElement
  local row = CreateFrame("Button", nil, parent)
  local padding = Design.window.menu.padding
  SetPixelPoint(row, "TOPLEFT", parent, "TOPLEFT", padding, yOffset)
  SetPixelPoint(row, "TOPRIGHT", parent, "TOPRIGHT", -padding, yOffset)
  SetPixelHeight(row, tokens.height)
  setButtonLabel(row, text)
  local label = row:GetFontString()
  label:ClearAllPoints()
  SetPixelPoint(label, "LEFT", row, "LEFT", tokens.padding or layout.gap, 0)
  label:SetJustifyH("LEFT")
  setupElement(row, tokens)
  row:SetScript("OnClick", function()
    selectPage(pageId)
  end)
  return row
end

local function openPrimaryPicker()
  local r, g, b = Design:GetPrimary()
  ColorPickerFrame:SetupColorPickerAndShow({
    r = r,
    g = g,
    b = b,
    hasOpacity = false,
    swatchFunc = function()
      local nr, ng, nb = ColorPickerFrame:GetColorRGB()
      Design:SetPrimary(nr, ng, nb)
    end,
    cancelFunc = function(previous)
      if previous and previous.r then
        Design:SetPrimary(previous.r, previous.g, previous.b)
      end
    end,
  })
end

local function savePoint()
  local point, _, relativePoint, x, y = sandbox:GetPoint()
  Design:GetDB().point = {point, relativePoint, x, y}
end

local function applySavedPoint()
  local point = Design:GetDB().point
  sandbox:ClearAllPoints()
  if point then
    SetPixelPoint(sandbox, point[1], UIParent, point[2], point[3], point[4])
    return
  end
  SetPixelPoint(sandbox, "CENTER", UIParent, "CENTER", 0, 0)
end

---@param parent Frame
---@param keys string[]
---@param source table
---@param yOffset number
---@param heading string
---@return number
local function layoutSwatchRow(parent, keys, source, yOffset, heading)
  local rowY = yOffset
  if heading ~= "" then
    local headingLabel = createTypeString(parent, "h3")
    SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, yOffset)
    headingLabel:SetText(heading)
    rowY = yOffset - 22
  end

  for index = 1, #keys do
    local key = keys[index]
    local swatch = createSwatch(parent, source[key], key)
    SetPixelPoint(swatch, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding + (index - 1) * (layout.swatchSize + layout.swatchGap), rowY)
  end
  return rowY - layout.swatchSize - layout.sectionGap
end

---@param parent Frame
---@param tokens LiqUI_DesignElement
---@param heading string
---@param yOffset number
---@return number
local function layoutButtonStateRow(parent, tokens, heading, yOffset)
  local headingLabel = createTypeString(parent, "h3")
  SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", Design.window.body.padding, yOffset)
  headingLabel:SetText(heading)

  local rest = createSampleButton(parent, tokens, "Rest", {})
  SetPixelPoint(rest, "TOPLEFT", headingLabel, "BOTTOMLEFT", 0, -6)

  local hover = createSampleButton(parent, tokens, "Hover", {})
  hover.previewOver = true
  hover:Apply()
  SetPixelPoint(hover, "LEFT", rest, "RIGHT", layout.gap, 0)

  local pressed = createSampleButton(parent, tokens, "Pressed", {})
  pressed.previewDown = true
  pressed:Apply()
  SetPixelPoint(pressed, "LEFT", hover, "RIGHT", layout.gap, 0)

  local disabled = createSampleButton(parent, tokens, "Disabled", {})
  disabled:Disable()
  SetPixelPoint(disabled, "LEFT", pressed, "RIGHT", layout.gap, 0)

  return yOffset - layout.sectionGap - tokens.height - layout.sectionGap
end

---@param parent Frame
---@param typeId LiqUI_DesignTypeId
---@param text string
---@param stackOptions LiqUI_DesignStackOptions
local function addTextSample(parent, typeId, text, stackOptions)
  local fontString = createTypeString(parent, typeId)
  fontString:SetJustifyH("LEFT")
  ---@type LiqUI_DesignSizeOptions
  local sizeOptions = {width = "100%"}
  Design:ApplySize(fontString, sizeOptions)
  Design:Stack(parent, fontString, stackOptions)
  fontString:SetText(text)
  Design:RequestStackLayout(parent)
end

local function paintSandbox()
  if not sandbox then
    return
  end
  SetPixelSize(sandbox, Design.window.width, Design.window.height)
  Design:PaintAll()
  local colors = Design.colors
  sandbox.body.colorsPage.primaryLabel:SetText("Primary  #" .. colors.primary:GenerateHexColorNoAlpha())
  for index = 1, #colorBindings do
    local binding = colorBindings[index]
    binding.texture:SetColorTexture(colorRGBA(binding.color))
  end
  for index = 1, #typeSamples do
    local sample = typeSamples[index]
    Design:ApplyType(sample.fontString, sample.typeId)
  end
  Design:LayoutStacks()
  local textScrollBox = sandbox.body.textPage.scrollBox
  if textScrollBox then
    textScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
  local tableScrollBox = sandbox.body.tablePage.scrollBox
  if tableScrollBox then
    tableScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
  local windowScrollBox = sandbox.body.windowPage.scrollBox
  if windowScrollBox then
    windowScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
  local panelScrollBox = sandbox.body.panelPage.scrollBox
  if panelScrollBox then
    panelScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
  for index = 1, #panelScrollBoxes do
    panelScrollBoxes[index]:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
end

local function buildSandbox()
  local windowTokens = Design.window
  ---@class LiqUI_DesignSandbox
  local window = CreateFrame("Frame", "LiqUIDesignSandbox", UIParent)
  sandbox = window
  setupElement(window, windowTokens)
  SetPixelSize(window, windowTokens.width, windowTokens.height)
  window:SetFrameStrata("HIGH")
  window:SetClampedToScreen(true)
  window:SetMovable(true)
  window:EnableMouse(true)
  applySavedPoint()

  ---@class LiqUI_DesignSandboxTitlebar
  local titlebar = CreateFrame("Frame", nil, window)
  window.titlebar = titlebar
  setupElement(titlebar, windowTokens.titlebar)
  SetPixelPoint(titlebar, "TOPLEFT", window, "TOPLEFT", 0, 0)
  SetPixelPoint(titlebar, "TOPRIGHT", window, "TOPRIGHT", 0, 0)
  SetPixelHeight(titlebar, windowTokens.titlebar.height)
  titlebar:EnableMouse(true)
  titlebar:RegisterForDrag("LeftButton")
  titlebar:SetScript("OnDragStart", function()
    window:StartMoving()
  end)
  titlebar:SetScript("OnDragStop", function()
    window:StopMovingOrSizing()
    savePoint()
  end)

  local title = createTypeString(titlebar, "title")
  titlebar.title = title
  SetPixelPoint(title, "LEFT", titlebar, "LEFT", 12, 0)
  title:SetText("LiqUI Design")

  local closeButton = createTitlebarButton(titlebar, "X")
  titlebar.CloseButton = closeButton
  SetPixelPoint(closeButton, "RIGHT", titlebar, "RIGHT", 0, 0)
  closeButton:SetScript("OnClick", function()
    window:Hide()
  end)

  ---@class LiqUI_DesignSandboxMenu
  local menu = CreateFrame("Frame", nil, window)
  window.menu = menu
  setupElement(menu, windowTokens.menu)
  SetPixelPoint(menu, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  SetPixelPoint(menu, "BOTTOMLEFT", window, "BOTTOMLEFT", 0, 0)
  SetPixelWidth(menu, windowTokens.menu.width)

  ---@class LiqUI_DesignSandboxBody
  local body = CreateFrame("Frame", nil, window)
  window.body = body
  setupElement(body, windowTokens.body)
  SetPixelPoint(body, "TOPLEFT", titlebar, "BOTTOMLEFT", windowTokens.menu.width, 0)
  SetPixelPoint(body, "BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 0)

  ---@class LiqUI_DesignSandboxColorsPage
  local colorsPage = CreateFrame("Frame", nil, body)
  body.colorsPage = colorsPage
  colorsPage:SetAllPoints()

  local primaryLabel = createTypeString(colorsPage, "h1")
  colorsPage.primaryLabel = primaryLabel
  SetPixelPoint(primaryLabel, "TOPLEFT", colorsPage, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)

  local primarySwatch = createSwatch(colorsPage, Design.colors.primary, "Click to change", openPrimaryPicker)
  colorsPage.primarySwatch = primarySwatch
  SetPixelPoint(primarySwatch, "TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -8)
  SetPixelSize(primarySwatch, 72, 36)

  local yOffset = -Design.window.body.padding - 90
  yOffset = layoutSwatchRow(colorsPage, FIXED_KEYS, Design.colors, yOffset, "Fixed")
  yOffset = layoutSwatchRow(colorsPage, TINT_KEYS, Design.colors, yOffset, "Tints  (toward white)")
  yOffset = layoutSwatchRow(colorsPage, SHADE_KEYS_NEAR, Design.colors, yOffset, "Shades  (toward black)")
  layoutSwatchRow(colorsPage, SHADE_KEYS_FAR, Design.colors, yOffset, "")

  ---@class LiqUI_DesignSandboxWindowPage
  local windowPage = CreateFrame("Frame", nil, body)
  body.windowPage = windowPage
  windowPage:SetAllPoints()
  windowPage:Hide()

  ---@type LiqUI_ScrollBoxOptions
  local windowScrollOptions = {barWidth = layout.scrollBar}
  local windowScrollBox = CreateScrollBox(windowPage, nil, windowScrollOptions)
  windowPage.scrollBox = windowScrollBox
  SetPixelPoint(windowScrollBox, "TOPLEFT", windowPage, "TOPLEFT", 0, 0)
  SetPixelPoint(windowScrollBox, "BOTTOMRIGHT", windowPage, "BOTTOMRIGHT", -layout.scrollBar, 0)
  local windowChild = windowScrollBox.scrollChild
  BindScrollBoxMouseWheel(windowPage, windowScrollBox)
  Design:SetPadding(windowChild, Design.window.body.padding)

  local windowHeading = createTypeString(windowChild, "h1")
  windowPage.heading = windowHeading
  SetPixelPoint(windowHeading, "TOPLEFT", windowChild, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)
  windowHeading:SetText("Window")

  local windowY = -Design.window.body.padding - windowHeading:GetStringHeight() - layout.sectionGap
  windowY = addWindowSample(windowChild, windowY, "Fill", {})
  windowY = addWindowSample(windowChild, windowY, "Body shade80", {bodyBackground = "shade80"})
  windowY = addWindowSample(windowChild, windowY, "Body shade90", {bodyBackground = "shade90"})
  windowY = addWindowSample(windowChild, windowY, "Overlay", {showOverlay = true})
  windowY = addWindowSample(windowChild, windowY, "Overlay, 90%", {showOverlay = true, overlayAlpha = 0.9})
  windowChild:SetHeight(math.max(1, -windowY + Design.window.body.padding))
  windowScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

  ---@class LiqUI_DesignSandboxPanelPage
  local panelPage = CreateFrame("Frame", nil, body)
  body.panelPage = panelPage
  panelPage:SetAllPoints()
  panelPage:Hide()

  ---@type LiqUI_ScrollBoxOptions
  local panelPageScrollOptions = {barWidth = layout.scrollBar}
  local panelPageScrollBox = CreateScrollBox(panelPage, nil, panelPageScrollOptions)
  panelPage.scrollBox = panelPageScrollBox
  SetPixelPoint(panelPageScrollBox, "TOPLEFT", panelPage, "TOPLEFT", 0, 0)
  SetPixelPoint(panelPageScrollBox, "BOTTOMRIGHT", panelPage, "BOTTOMRIGHT", -layout.scrollBar, 0)
  local panelChild = panelPageScrollBox.scrollChild
  BindScrollBoxMouseWheel(panelPage, panelPageScrollBox)
  Design:SetPadding(panelChild, Design.window.body.padding)
  ---@type LiqUI_DesignStackOptions
  local panelStack = {
    padding = Design.window.body.padding,
    gap = layout.sectionGap,
    onLayout = function()
      panelPageScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end,
  }
  local panelHeading = createTypeString(panelChild, "h1")
  panelPage.heading = panelHeading
  panelHeading:SetText("Panel")
  ---@type LiqUI_DesignSizeOptions
  local panelHeadingSize = {width = "100%"}
  Design:ApplySize(panelHeading, panelHeadingSize)
  Design:Stack(panelChild, panelHeading, panelStack)
  addPanelSample(panelChild, "Fill", {
    showBackground = true,
    text = "A panel can be a fill with padding and no header.",
  }, panelStack)
  addPanelSample(panelChild, "Header", {
    title = "Notes",
    showBackground = true,
    text = "Optional header, no buttons. Fill uses shade80.",
  }, panelStack)
  addPanelSample(panelChild, "Header, border", {
    title = "Notes",
    showBackground = true,
    showBorder = true,
    text = "Header, fill, and border together.",
  }, panelStack)
  addPanelSample(panelChild, "Header, no header fill", {
    title = "Caption",
    showBackground = true,
    showHeaderBackground = false,
    text = "The header can be text only.",
  }, panelStack)
  addPanelSample(panelChild, "Padding only", {
    padding = 16,
    text = "No fill, no border, no header. Padding still insets the copy.",
  }, panelStack)
  addPanelSample(panelChild, "Header, max height", {
    title = "Preview",
    showBackground = true,
    showBorder = true,
    maxHeight = PANEL_SCROLL_HEIGHT,
    text = LOREM_BLOCK,
  }, panelStack)

  ---@class LiqUI_DesignSandboxTablePage
  local tablePage = CreateFrame("Frame", nil, body)
  body.tablePage = tablePage
  tablePage:SetAllPoints()
  tablePage:Hide()

  ---@type LiqUI_ScrollBoxOptions
  local tableScrollOptions = {barWidth = layout.scrollBar}
  local tableScrollBox = CreateScrollBox(tablePage, nil, tableScrollOptions)
  tablePage.scrollBox = tableScrollBox
  SetPixelPoint(tableScrollBox, "TOPLEFT", tablePage, "TOPLEFT", 0, 0)
  SetPixelPoint(tableScrollBox, "BOTTOMRIGHT", tablePage, "BOTTOMRIGHT", -layout.scrollBar, 0)
  local tableChild = tableScrollBox.scrollChild
  BindScrollBoxMouseWheel(tablePage, tableScrollBox)
  Design:SetPadding(tableChild, Design.window.body.padding)

  local tableHeading = createTypeString(tableChild, "h1")
  tablePage.heading = tableHeading
  SetPixelPoint(tableHeading, "TOPLEFT", tableChild, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)
  tableHeading:SetText("Table")

  local tableY = -Design.window.body.padding - tableHeading:GetStringHeight() - layout.sectionGap
  tableY = addTableSample(tableChild, tableY, "Fill", {})
  tableY = addTableSample(tableChild, tableY, "Border", {showBorder = true})
  tableY = addTableSample(tableChild, tableY, "Stripes", {stripes = true})
  tableY = addTableSample(tableChild, tableY, "Hover", {highlightRows = true})
  tableY = addTableSample(tableChild, tableY, "Border, stripes", {showBorder = true, stripes = true})
  tableY = addTableSample(tableChild, tableY, "Border, hover", {showBorder = true, highlightRows = true})
  tableY = addTableSample(tableChild, tableY, "Stripes, hover", {stripes = true, highlightRows = true})
  tableY = addTableSample(tableChild, tableY, "Border, stripes, hover", {showBorder = true, stripes = true, highlightRows = true})
  tableChild:SetHeight(math.max(1, -tableY + Design.window.body.padding))
  tableScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

  ---@class LiqUI_DesignSandboxButtonsPage
  local buttonsPage = CreateFrame("Frame", nil, body)
  body.buttonsPage = buttonsPage
  buttonsPage:SetAllPoints()
  buttonsPage:Hide()

  local buttonsHeading = createTypeString(buttonsPage, "h1")
  buttonsPage.heading = buttonsHeading
  SetPixelPoint(buttonsHeading, "TOPLEFT", buttonsPage, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)
  buttonsHeading:SetText("Buttons")

  local buttonY = -Design.window.body.padding - buttonsHeading:GetStringHeight() - layout.sectionGap
  buttonY = layoutButtonStateRow(buttonsPage, Design.button.primary, "Primary", buttonY)
  buttonY = layoutButtonStateRow(buttonsPage, Design.button.secondary, "Secondary", buttonY)

  local pairLabel = createTypeString(buttonsPage, "h3")
  SetPixelPoint(pairLabel, "TOPLEFT", buttonsPage, "TOPLEFT", Design.window.body.padding, buttonY)
  pairLabel:SetText("Save and Cancel")

  local saveButton = createSampleButton(buttonsPage, Design.button.primary, "Save")
  SetPixelPoint(saveButton, "TOPLEFT", pairLabel, "BOTTOMLEFT", 0, -6)
  local cancelButton = createSampleButton(buttonsPage, Design.button.secondary, "Cancel")
  SetPixelPoint(cancelButton, "LEFT", saveButton, "RIGHT", layout.gap, 0)

  ---@class LiqUI_DesignSandboxInputPage
  local inputPage = CreateFrame("Frame", nil, body)
  body.inputPage = inputPage
  inputPage:SetAllPoints()
  inputPage:Hide()

  local inputHeading = createTypeString(inputPage, "h1")
  inputPage.heading = inputHeading
  SetPixelPoint(inputHeading, "TOPLEFT", inputPage, "TOPLEFT", Design.window.body.padding, -Design.window.body.padding)
  inputHeading:SetText("Input")

  local nameLabel = createTypeString(inputPage, "label")
  SetPixelPoint(nameLabel, "TOPLEFT", inputHeading, "BOTTOMLEFT", 0, -16)
  nameLabel:SetText("With text")

  local nameInput = createSampleInput(inputPage, "Player name", true)
  inputPage.nameInput = nameInput
  SetPixelPoint(nameInput, "TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6)

  local emptyLabel = createTypeString(inputPage, "label")
  SetPixelPoint(emptyLabel, "TOPLEFT", nameInput, "BOTTOMLEFT", 0, -16)
  emptyLabel:SetText("Placeholder")

  local emptyInput = createSampleInput(inputPage, "", true, "Character name")
  inputPage.emptyInput = emptyInput
  SetPixelPoint(emptyInput, "TOPLEFT", emptyLabel, "BOTTOMLEFT", 0, -6)

  local disabledLabel = createTypeString(inputPage, "label")
  SetPixelPoint(disabledLabel, "TOPLEFT", emptyInput, "BOTTOMLEFT", 0, -16)
  disabledLabel:SetText("Disabled")

  local disabledInput = createSampleInput(inputPage, "Cannot edit", false)
  inputPage.disabledInput = disabledInput
  SetPixelPoint(disabledInput, "TOPLEFT", disabledLabel, "BOTTOMLEFT", 0, -6)

  ---@class LiqUI_DesignSandboxTextPage
  local textPage = CreateFrame("Frame", nil, body)
  body.textPage = textPage
  textPage:SetAllPoints()
  textPage:Hide()

  ---@type LiqUI_ScrollBoxOptions
  local scrollBoxOptions = {barWidth = layout.scrollBar}
  local scrollBox = CreateScrollBox(textPage, nil, scrollBoxOptions)
  textPage.scrollBox = scrollBox
  SetPixelPoint(scrollBox, "TOPLEFT", textPage, "TOPLEFT", 0, 0)
  SetPixelPoint(scrollBox, "BOTTOMRIGHT", textPage, "BOTTOMRIGHT", -layout.scrollBar, 0)
  local scrollChild = scrollBox.scrollChild
  BindScrollBoxMouseWheel(textPage, scrollBox)
  Design:SetPadding(scrollChild, Design.window.body.padding)
  ---@type LiqUI_DesignStackOptions
  local textStack = {
    gap = 8,
    onLayout = function()
      scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end,
  }
  addTextSample(scrollChild, "h1", "h1 is the page title.", textStack)
  addTextSample(
    scrollChild,
    "p",
    "p is body copy. It wraps inside the content width. The window titlebar uses title, not h1.",
    textStack
  )
  addTextSample(scrollChild, "p", LOREM_BLOCK, textStack)
  addTextSample(scrollChild, "h2", "h2 is a section heading.", textStack)
  addTextSample(scrollChild, "p", LOREM_BLOCK, textStack)
  addTextSample(scrollChild, "p", LOREM_PARAGRAPH, textStack)
  addTextSample(scrollChild, "h3", "h3 is a subsection heading.", textStack)
  addTextSample(scrollChild, "p", LOREM_BLOCK, textStack)
  addTextSample(scrollChild, "label", "label is a field caption.", textStack)
  addTextSample(scrollChild, "p", LOREM_PARAGRAPH_TWO, textStack)
  addTextSample(scrollChild, "h2", "Another section heading.", textStack)
  addTextSample(scrollChild, "p", LOREM_BLOCK, textStack)
  addTextSample(scrollChild, "h3", "Another subsection heading.", textStack)
  addTextSample(scrollChild, "p", LOREM_BLOCK, textStack)

  local menuRow = Design.window.menu.row
  local menuStep = menuRow.height + menuRow.gap
  local menuPadding = Design.window.menu.padding
  local colorsRow = createMenuRow(menu, "Colors", "colors", -menuPadding)
  menu.colorsRow = colorsRow
  local windowRow = createMenuRow(menu, "Window", "window", -(menuPadding + menuStep))
  menu.windowRow = windowRow
  local panelRow = createMenuRow(menu, "Panel", "panel", -(menuPadding + menuStep * 2))
  menu.panelRow = panelRow
  local tableRow = createMenuRow(menu, "Table", "table", -(menuPadding + menuStep * 3))
  menu.tableRow = tableRow
  local buttonsRow = createMenuRow(menu, "Buttons", "buttons", -(menuPadding + menuStep * 4))
  menu.buttonsRow = buttonsRow
  local inputRow = createMenuRow(menu, "Input", "input", -(menuPadding + menuStep * 5))
  menu.inputRow = inputRow
  local textRow = createMenuRow(menu, "Text", "text", -(menuPadding + menuStep * 6))
  menu.textRow = textRow
  selectPage("colors")

  window:SetScript("OnShow", paintSandbox)
  Design:RegisterOnChanged(paintSandbox)
  window:Show()
end

local function showSandbox()
  if not sandbox then
    buildSandbox()
    return
  end
  sandbox:Show()
end

---@param _frame Frame
---@param _event string
---@param loadedName string
local function onAddonLoaded(_frame, _event, loadedName)
  if loadedName ~= "LiqUI" then
    return
  end
  Events:UnregisterEvent("ADDON_LOADED", onAddonLoaded)
  local store = Design:GetDB()
  Design:SetPrimary(store.primary.r, store.primary.g, store.primary.b)
  showSandbox()
end

Events:RegisterEvent("ADDON_LOADED", onAddonLoaded, true)
Events:RegisterEvent("UI_SCALE_CHANGED", paintSandbox, true)
Events:RegisterEvent("DISPLAY_SIZE_CHANGED", paintSandbox, true)
