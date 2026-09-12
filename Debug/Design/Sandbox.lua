---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design
local layout = Design.layout
local windowChrome = Design.window
local tableChrome = Design.table
local Events = LiqUI.Events
local SetBackgroundColor = LiqUI.Utils.SetBackgroundColor
local SetPixelBackdrop = LiqUI.Utils.SetPixelBackdrop
local CreateScrollBox = LiqUI.Utils.CreateScrollBox
local BindScrollBoxMouseWheel = LiqUI.Utils.BindScrollBoxMouseWheel
local SetPixelPoint = PixelUtil.SetPoint
local SetPixelSize = PixelUtil.SetSize
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
---@type number[]
local TABLE_COLUMNS = {42, 33, 25}
local TABLE_STRIPE_ROWS = {
  {"Liquidor", "Tank", "2840"},
  {"Calia", "Healer", "2715"},
  {"Toren", "DPS", "3120"},
  {"Mara", "DPS", "3055"},
  {"Bren", "Tank", "2988"},
  {"Syla", "Healer", "2764"},
  {"Oric", "DPS", "3210"},
  {"Nera", "DPS", "2891"},
  {"Kael", "Tank", "2650"},
  {"Ryn", "Healer", "2542"},
  {"Voss", "DPS", "3340"},
  {"Lira", "DPS", "3012"},
  {"Dain", "Tank", "2888"},
  {"Pell", "Healer", "2699"},
  {"Jace", "DPS", "3175"},
  {"Wren", "DPS", "2920"},
  {"Hale", "Tank", "2733"},
  {"Mio", "Healer", "2610"},
  {"Quinn", "DPS", "3088"},
  {"Ash", "DPS", "2954"},
  {"Bram", "Tank", "2801"},
  {"Cora", "Healer", "2588"},
  {"Ellis", "DPS", "3266"},
  {"Faye", "DPS", "2999"},
}
local TINT_KEYS = {"tint5", "tint10", "tint15", "tint20", "tint25", "tint30", "tint35", "tint40", "tint45", "tint50"}
local SHADE_KEYS = {"shade10", "shade20", "shade30", "shade40", "shade50", "shade60", "shade70", "shade80", "shade90"}
local WHITE8X8 = "Interface/BUTTONS/WHITE8X8"
local LOREM_PARAGRAPH =
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
local LOREM_PARAGRAPH_TWO =
  "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem."
local LOREM_BLOCK = LOREM_PARAGRAPH .. " " .. LOREM_PARAGRAPH_TWO .. " " .. LOREM_PARAGRAPH .. " " .. LOREM_PARAGRAPH_TWO

---@type LiqUI_DesignSandbox?
local sandbox
---@type LiqUI_DesignColorBinding[]
local colorBindings = {}
---@type LiqUI_DesignSandboxControl[]
local controls = {}
---@type LiqUI_DesignTypeSample[]
local typeSamples = {}
---@type LiqUI_DesignSandboxWindowSample[]
local windowSamples = {}
---@type LiqUI_DesignSandboxTableSample[]
local tableSamples = {}

---@param color ColorMixin
---@return number, number, number, number
local function colorRGBA(color)
  return color:GetRGBA()
end

local function setPixelInsetFill(region, fill, inset)
  inset = inset or 1
  fill:ClearAllPoints()
  SetPixelPoint(fill, "TOPLEFT", region, "TOPLEFT", inset, -inset, 1, 1)
  SetPixelPoint(fill, "BOTTOMRIGHT", region, "BOTTOMRIGHT", -inset, inset, 1, 1)
end

---@param row LiqUI_DesignSandboxControl
---@return number
local function controlBorderPixels(row)
  return row.style.borderPixels or 0
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

---@param row LiqUI_DesignSandboxControl
---@return LiqUI_DesignControlState
local function controlState(row)
  ---@type LiqUI_DesignControlState
  local state = {
    enabled = row:IsEnabled(),
    over = row.previewOver or (row:IsOver() and true) or false,
    down = row.previewDown or (row:IsDown() and true) or false,
    selected = row.selected,
    focused = row.focused,
    alt = row.alt,
  }
  return state
end

---@param row LiqUI_DesignSandboxControl
local function paintControl(row)
  local scale = Design.scale
  local style = row.style
  local state = controlState(row)
  state.over = state.over and row.hover
  state.down = state.down and row.hover
  local fill = Design:ResolveFill(style, state)
  row.Fill:SetVertexColor(colorRGBA(fill))
  row.Wash:SetVertexColor(Design:ResolveWash(style, state))
  local textColor = scale.white
  if not state.enabled then
    textColor = scale.tint50
  end
  local fontString = row.GetFontString and row:GetFontString()
  if fontString then
    fontString:SetTextColor(colorRGBA(textColor))
  end
  local border = Design:ResolveBorder(style, state, fill)
  if border then
    row:SetBackdropBorderColor(colorRGBA(border))
  end
  if style.textInset then
    row:SetTextColor(colorRGBA(textColor))
  end
  local instructions = row.Instructions
  if instructions then
    instructions:SetTextColor(colorRGBA(scale.tint50))
    instructions:SetShown(row:GetText() == "")
  end
end

---@param row LiqUI_DesignSandboxControl
---@param style LiqUI_DesignStyle
local function setupControl(row, style)
  row.style = style
  row.hover = style.hover
  Mixin(row, ButtonStateBehaviorMixin)
  local fillLayer = style.fillLayer or "ARTWORK"
  local fill = row:CreateTexture(nil, fillLayer)
  fill:SetDrawLayer(fillLayer, 0)
  fill:SetTexture(WHITE8X8)
  row.Fill = fill
  local wash = row:CreateTexture(nil, "ARTWORK")
  wash:SetDrawLayer("ARTWORK", 1)
  wash:SetTexture(WHITE8X8)
  row.Wash = wash
  local borderPixels = style.borderPixels or 0
  if borderPixels > 0 then
    SetPixelBackdrop(row, borderPixels, false)
    setPixelInsetFill(row, fill, borderPixels)
    setPixelInsetFill(row, wash, borderPixels)
  else
    fill:SetAllPoints()
    wash:SetAllPoints()
  end
  row:SetScript("OnEnter", row.OnEnter)
  row:SetScript("OnLeave", row.OnLeave)
  row:SetScript("OnMouseDown", row.OnMouseDown)
  row:SetScript("OnMouseUp", row.OnMouseUp)
  if not style.textInset then
    row:SetScript("OnEnable", row.OnEnable)
    row:SetScript("OnDisable", row.OnDisable)
  end
  row.OnButtonStateChanged = paintControl
  table.insert(controls, row)
end

---@param parent Frame
---@param style LiqUI_DesignStyle
---@param text string
---@param options LiqUI_DesignElementOptions?
---@return LiqUI_DesignSandboxControl
local function createSampleButton(parent, style, text, options)
  options = options or {}
  local template
  if (style.borderPixels or 0) > 0 then
    template = "BackdropTemplate"
  end
  ---@class LiqUI_DesignSandboxControl
  local button = CreateFrame("Button", nil, parent, template)
  setButtonLabel(button, text)
  setupControl(button, style)
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {
    width = options.width or style.width,
    height = options.height or style.height,
  }
  Design:ApplySize(button, sizeOptions)
  return button
end

---@param parent Frame
---@param text string
---@return LiqUI_DesignSandboxControl
local function createTitlebarButton(parent, text)
  local style = Design.titlebar.button
  ---@class LiqUI_DesignSandboxControl
  local button = CreateFrame("Button", nil, parent)
  setButtonLabel(button, text)
  setupControl(button, style)
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {width = style.width, height = style.height}
  Design:ApplySize(button, sizeOptions)
  return button
end

---@param parent Frame
---@param text string
---@param enabled boolean?
---@param placeholder string?
---@return LiqUI_DesignSandboxControl
local function createSampleInput(parent, text, enabled, placeholder)
  ---@class LiqUI_DesignSandboxControl
  local input = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
  input:SetAutoFocus(false)
  local labelStyle = Design.typography.label
  local style = Design.input
  input:SetFont(Design.fontFile, labelStyle.size, labelStyle.flags or Design.fontFlags)
  input:SetTextInsets(style.textInset, style.textInset, 0, 0)
  input:SetText(text or "")
  setupControl(input, style)
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {width = "50%", height = style.height}
  Design:SetPadding(parent, layout.padding)
  Design:ApplySize(input, sizeOptions)
  if placeholder then
    local instructions = input:CreateFontString(nil, "OVERLAY")
    Design:ApplyType(instructions, "label")
    instructions:SetJustifyH("LEFT")
    SetPixelPoint(instructions, "TOPLEFT", input, "TOPLEFT", style.textInset, 0)
    SetPixelPoint(instructions, "BOTTOMRIGHT", input, "BOTTOMRIGHT", -style.textInset, 0)
    instructions:SetText(placeholder)
    input.Instructions = instructions
  end
  input:SetScript("OnEditFocusGained", function(self)
    self.focused = true
    paintControl(self)
  end)
  input:SetScript("OnEditFocusLost", function(self)
    self.focused = false
    paintControl(self)
  end)
  input:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  input:SetScript("OnTextChanged", function(self)
    paintControl(self)
  end)
  if enabled == false then
    input:Disable()
  end
  return input
end

---@param parent Frame
---@param title string
---@param showSettings boolean
---@param showOverlay boolean
---@return LiqUI_DesignSandboxWindowSample
local function createSampleWindow(parent, title, showSettings, showOverlay)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  SetPixelBackdrop(frame, windowChrome.borderPixels, true)
  ---@type LiqUI_DesignElementOptions
  local windowSize = {width = "90%", height = windowChrome.sampleHeight}
  Design:SetPadding(parent, layout.padding)
  Design:ApplySize(frame, windowSize)

  local titlebar = CreateFrame("Frame", nil, frame)
  SetPixelPoint(titlebar, "TOPLEFT", frame, "TOPLEFT", 1, -1, 1, 1)
  SetPixelPoint(titlebar, "TOPRIGHT", frame, "TOPRIGHT", -1, -1, 1, 1)
  SetPixelHeight(titlebar, windowChrome.titlebarHeight)

  local titleText = createTypeString(titlebar, "title")
  SetPixelPoint(titleText, "LEFT", titlebar, "LEFT", 12, 0)
  titleText:SetText(title)

  local closeButton = createTitlebarButton(titlebar, "X")
  SetPixelPoint(closeButton, "RIGHT", titlebar, "RIGHT", 0, 0)

  if showSettings then
    local settingsButton = createTitlebarButton(titlebar, "S")
    SetPixelPoint(settingsButton, "RIGHT", closeButton, "LEFT", 0, 0)
  end

  local body = CreateFrame("Frame", nil, frame)
  SetPixelPoint(body, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  SetPixelPoint(body, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1, 1, 1)

  local bodyCopy = createTypeString(body, "p")
  SetPixelPoint(bodyCopy, "TOPLEFT", body, "TOPLEFT", layout.padding, -layout.padding)
  bodyCopy:SetJustifyH("LEFT")
  ---@type LiqUI_DesignElementOptions
  local bodyCopySize = {width = "100%"}
  Design:SetPadding(body, layout.padding)
  Design:ApplySize(bodyCopy, bodyCopySize)
  bodyCopy:SetText("Body uses shade70. Titlebar uses shade90. Border uses shade50.")

  local overlay
  if showOverlay then
    overlay = CreateFrame("Frame", nil, frame)
    overlay:EnableMouse(true)
    SetPixelPoint(overlay, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
    SetPixelPoint(overlay, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1, 1, 1)
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
  table.insert(windowSamples, sample)
  return sample
end

---@param sample LiqUI_DesignSandboxWindowSample
local function paintWindowSample(sample)
  local scale = Design.scale
  sample.frame:SetBackdropColor(colorRGBA(scale[windowChrome.fill]))
  sample.frame:SetBackdropBorderColor(colorRGBA(scale[windowChrome.border]))
  SetBackgroundColor(sample.titlebar, scale[windowChrome.titlebar])
  SetBackgroundColor(sample.body, scale[windowChrome.body])
  if sample.overlay then
    local red, green, blue = scale[windowChrome.titlebar]:GetRGB()
    SetBackgroundColor(sample.overlay, red, green, blue, windowChrome.overlayAlpha)
  end
end

---@param parent Frame
---@param style LiqUI_DesignStyle
---@param texts string[]
---@param yOffset number
---@param options LiqUI_DesignTableRowOptions
---@return LiqUI_DesignSandboxControl, number
local function createTableRow(parent, style, texts, yOffset, options)
  options = options or {}
  ---@class LiqUI_DesignSandboxControl
  local row = CreateFrame("Button", nil, parent)
  local inset = options.inset or 0
  SetPixelPoint(row, "TOPLEFT", parent, "TOPLEFT", inset, yOffset)
  setupControl(row, style)
  if options.hover ~= nil then
    row.hover = options.hover
  end
  row.alt = options.alt
  row:EnableMouse(row.hover and true or false)
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {width = "100%", height = tableChrome.rowHeight}
  Design:ApplySize(row, sizeOptions)
  ---@type FontString[]
  local cells = {}
  row.cells = cells
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
      SetPixelPoint(cell, "LEFT", row, "LEFT", columnOffset + tableChrome.cellPad, 0)
      SetPixelWidth(cell, math.max(1, width - tableChrome.cellPad * 2))
      columnOffset = columnOffset + width
    end
  end
  row:HookScript("OnSizeChanged", layoutCells)
  layoutCells()
  return row, yOffset - tableChrome.rowHeight
end

---@param tableOptions LiqUI_DesignTableOptions
---@param isHeader boolean
---@param inset number
---@param alt boolean?
---@return LiqUI_DesignTableRowOptions
local function tableRowOptions(tableOptions, isHeader, inset, alt)
  local hover = tableOptions.hoverRows
  if hover == nil then
    hover = tableChrome.hoverRows
  end
  if isHeader then
    hover = tableOptions.headerHover
    if hover == nil then
      hover = tableChrome.headerHover
    end
  end
  ---@type LiqUI_DesignTableRowOptions
  local rowOptions = {hover = hover and true or false, inset = inset, alt = alt}
  return rowOptions
end

---@param parent Frame
---@param yOffset number
---@param options LiqUI_DesignTableOptions
---@return Frame, number, number
local function createTableShell(parent, yOffset, options)
  local showBorder = options.showBorder
  if showBorder == nil then
    showBorder = tableChrome.showBorder
  end
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  SetPixelPoint(frame, "TOPLEFT", parent, "TOPLEFT", layout.padding, yOffset)
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {width = "100%"}
  Design:ApplySize(frame, sizeOptions)
  local inset = 0
  if showBorder then
    inset = tableChrome.borderPixels
    SetPixelBackdrop(frame, inset, false)
    Design:SetPadding(frame, inset)
  end
  ---@type LiqUI_DesignSandboxTableSample
  local sample = {frame = frame, showBorder = showBorder}
  table.insert(tableSamples, sample)
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

---@param sample LiqUI_DesignSandboxTableSample
local function paintTableSample(sample)
  local scale = Design.scale
  SetBackgroundColor(sample.frame, scale[tableChrome.fill])
  if sample.showBorder then
    sample.frame:SetBackdropBorderColor(colorRGBA(scale[tableChrome.border]))
  end
end

---@param pageId LiqUI_DesignSandboxPageId
local function selectPage(pageId)
  if not sandbox then
    return
  end
  sandbox.menu.colorsRow.selected = pageId == "colors"
  sandbox.menu.windowRow.selected = pageId == "window"
  sandbox.menu.tableRow.selected = pageId == "table"
  sandbox.menu.buttonsRow.selected = pageId == "buttons"
  sandbox.menu.inputRow.selected = pageId == "input"
  sandbox.menu.textRow.selected = pageId == "text"
  sandbox.body.colorsPage:SetShown(pageId == "colors")
  sandbox.body.windowPage:SetShown(pageId == "window")
  sandbox.body.tablePage:SetShown(pageId == "table")
  sandbox.body.buttonsPage:SetShown(pageId == "buttons")
  sandbox.body.inputPage:SetShown(pageId == "input")
  sandbox.body.textPage:SetShown(pageId == "text")
  paintControl(sandbox.menu.colorsRow)
  paintControl(sandbox.menu.windowRow)
  paintControl(sandbox.menu.tableRow)
  paintControl(sandbox.menu.buttonsRow)
  paintControl(sandbox.menu.inputRow)
  paintControl(sandbox.menu.textRow)
  Design:LayoutStacks()
end

---@param parent Frame
---@param text string
---@param pageId LiqUI_DesignSandboxPageId
---@param yOffset number
---@return LiqUI_DesignSandboxControl
local function createMenuRow(parent, text, pageId, yOffset)
  ---@class LiqUI_DesignSandboxControl
  local row = CreateFrame("Button", nil, parent)
  SetPixelPoint(row, "TOPLEFT", parent, "TOPLEFT", layout.padding, yOffset)
  SetPixelPoint(row, "TOPRIGHT", parent, "TOPRIGHT", -layout.padding, yOffset)
  SetPixelHeight(row, Design.menu.row.height)
  setButtonLabel(row, text)
  local label = row:GetFontString()
  label:ClearAllPoints()
  SetPixelPoint(label, "LEFT", row, "LEFT", layout.gap, 0)
  label:SetJustifyH("LEFT")
  setupControl(row, Design.menu.row)
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
  local headingLabel = createTypeString(parent, "h3")
  SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", layout.padding, yOffset)
  headingLabel:SetText(heading)

  local rowY = yOffset - 22
  for index = 1, #keys do
    local key = keys[index]
    local swatch = createSwatch(parent, source[key], key)
    SetPixelPoint(swatch, "TOPLEFT", parent, "TOPLEFT", layout.padding + (index - 1) * (layout.swatchSize + layout.swatchGap), rowY)
  end
  return rowY - layout.swatchSize - layout.sectionGap
end

---@param parent Frame
---@param style LiqUI_DesignStyle
---@param heading string
---@param yOffset number
---@return number
local function layoutButtonStateRow(parent, style, heading, yOffset)
  local headingLabel = createTypeString(parent, "h3")
  SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", layout.padding, yOffset)
  headingLabel:SetText(heading)

  local rest = createSampleButton(parent, style, "Rest", {})
  SetPixelPoint(rest, "TOPLEFT", headingLabel, "BOTTOMLEFT", 0, -6)

  local hover = createSampleButton(parent, style, "Hover", {})
  hover.previewOver = true
  SetPixelPoint(hover, "LEFT", rest, "RIGHT", layout.gap, 0)

  local pressed = createSampleButton(parent, style, "Pressed", {})
  pressed.previewDown = true
  SetPixelPoint(pressed, "LEFT", hover, "RIGHT", layout.gap, 0)

  local disabled = createSampleButton(parent, style, "Disabled", {})
  disabled:Disable()
  SetPixelPoint(disabled, "LEFT", pressed, "RIGHT", layout.gap, 0)

  return yOffset - layout.sectionGap - style.height - layout.sectionGap
end

---@param parent Frame
---@param typeId LiqUI_DesignTypeId
---@param text string
---@param stackOptions LiqUI_DesignStackOptions
local function addTextSample(parent, typeId, text, stackOptions)
  local fontString = createTypeString(parent, typeId)
  fontString:SetJustifyH("LEFT")
  ---@type LiqUI_DesignElementOptions
  local sizeOptions = {width = "100%"}
  Design:ApplySize(fontString, sizeOptions)
  Design:Stack(parent, fontString, stackOptions)
  fontString:SetText(text)
  Design:RequestStackLayout(parent)
end

local function applyPixelBackdrops()
  if not sandbox then
    return
  end
  SetPixelSize(sandbox, windowChrome.width, windowChrome.height)
  SetPixelBackdrop(sandbox, windowChrome.borderPixels, true)
  for index = 1, #controls do
    local row = controls[index]
    local borderPixels = controlBorderPixels(row)
    if borderPixels > 0 then
      SetPixelBackdrop(row, borderPixels, false)
      setPixelInsetFill(row, row.Fill, borderPixels)
      setPixelInsetFill(row, row.Wash, borderPixels)
    end
  end
  for index = 1, #windowSamples do
    SetPixelBackdrop(windowSamples[index].frame, windowChrome.borderPixels, true)
  end
  for index = 1, #tableSamples do
    local sample = tableSamples[index]
    if sample.showBorder then
      SetPixelBackdrop(sample.frame, tableChrome.borderPixels, false)
    end
  end
end

local function paintSandbox()
  if not sandbox then
    return
  end
  applyPixelBackdrops()
  local scale = Design.scale
  sandbox:SetBackdropColor(colorRGBA(scale[windowChrome.fill]))
  sandbox:SetBackdropBorderColor(colorRGBA(scale[windowChrome.border]))
  SetBackgroundColor(sandbox.titlebar, scale[windowChrome.titlebar])
  SetBackgroundColor(sandbox.menu, scale[windowChrome.menu])
  SetBackgroundColor(sandbox.body, scale[windowChrome.body])
  for index = 1, #controls do
    paintControl(controls[index])
  end
  for index = 1, #windowSamples do
    paintWindowSample(windowSamples[index])
  end
  for index = 1, #tableSamples do
    paintTableSample(tableSamples[index])
  end
  sandbox.body.colorsPage.primaryLabel:SetText("Primary  #" .. scale.primary:GenerateHexColorNoAlpha())
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
end

local function buildSandbox()
  ---@class LiqUI_DesignSandbox
  local window = CreateFrame("Frame", "LiqUIDesignSandbox", UIParent, "BackdropTemplate")
  sandbox = window
  SetPixelSize(window, windowChrome.width, windowChrome.height)
  window:SetFrameStrata("HIGH")
  window:SetClampedToScreen(true)
  window:SetMovable(true)
  window:EnableMouse(true)
  applySavedPoint()

  ---@class LiqUI_DesignSandboxTitlebar
  local titlebar = CreateFrame("Frame", nil, window)
  window.titlebar = titlebar
  SetPixelPoint(titlebar, "TOPLEFT", window, "TOPLEFT", 1, -1, 1, 1)
  SetPixelPoint(titlebar, "TOPRIGHT", window, "TOPRIGHT", -1, -1, 1, 1)
  SetPixelHeight(titlebar, windowChrome.titlebarHeight)
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
  SetPixelPoint(menu, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  SetPixelPoint(menu, "BOTTOMLEFT", window, "BOTTOMLEFT", 1, 1, 1, 1)
  SetPixelWidth(menu, windowChrome.menuWidth)

  ---@class LiqUI_DesignSandboxBody
  local body = CreateFrame("Frame", nil, window)
  window.body = body
  SetPixelPoint(body, "TOPLEFT", titlebar, "BOTTOMLEFT", windowChrome.menuWidth, 0)
  SetPixelPoint(body, "BOTTOMRIGHT", window, "BOTTOMRIGHT", -1, 1, 1, 1)

  ---@class LiqUI_DesignSandboxColorsPage
  local colorsPage = CreateFrame("Frame", nil, body)
  body.colorsPage = colorsPage
  colorsPage:SetAllPoints()

  local primaryLabel = createTypeString(colorsPage, "h1")
  colorsPage.primaryLabel = primaryLabel
  SetPixelPoint(primaryLabel, "TOPLEFT", colorsPage, "TOPLEFT", layout.padding, -layout.padding)

  local primarySwatch = createSwatch(colorsPage, Design.scale.primary, "Click to change", openPrimaryPicker)
  colorsPage.primarySwatch = primarySwatch
  SetPixelPoint(primarySwatch, "TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -8)
  SetPixelSize(primarySwatch, 72, 36)

  local yOffset = -layout.padding - 90
  yOffset = layoutSwatchRow(colorsPage, TINT_KEYS, Design.scale, yOffset, "Tints  (toward white)")
  layoutSwatchRow(colorsPage, SHADE_KEYS, Design.scale, yOffset, "Shades  (toward black)")

  ---@class LiqUI_DesignSandboxWindowPage
  local windowPage = CreateFrame("Frame", nil, body)
  body.windowPage = windowPage
  windowPage:SetAllPoints()
  windowPage:Hide()

  local windowHeading = createTypeString(windowPage, "h1")
  windowPage.heading = windowHeading
  SetPixelPoint(windowHeading, "TOPLEFT", windowPage, "TOPLEFT", layout.padding, -layout.padding)
  windowHeading:SetText("Window")

  local defaultWindowLabel = createTypeString(windowPage, "h3")
  SetPixelPoint(defaultWindowLabel, "TOPLEFT", windowHeading, "BOTTOMLEFT", 0, -16)
  defaultWindowLabel:SetText("Default")

  local defaultWindow = createSampleWindow(windowPage, "Weekly vault", false, false)
  SetPixelPoint(defaultWindow.frame, "TOPLEFT", defaultWindowLabel, "BOTTOMLEFT", 0, -8)

  local overlayWindowLabel = createTypeString(windowPage, "h3")
  SetPixelPoint(overlayWindowLabel, "TOPLEFT", defaultWindow.frame, "BOTTOMLEFT", 0, -16)
  overlayWindowLabel:SetText("Overlay")

  local overlayWindow = createSampleWindow(windowPage, "Weekly vault", true, true)
  SetPixelPoint(overlayWindow.frame, "TOPLEFT", overlayWindowLabel, "BOTTOMLEFT", 0, -8)

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
  Design:SetPadding(tableChild, layout.padding)

  local tableHeading = createTypeString(tableChild, "h1")
  tablePage.heading = tableHeading
  SetPixelPoint(tableHeading, "TOPLEFT", tableChild, "TOPLEFT", layout.padding, -layout.padding)
  tableHeading:SetText("Table")

  local hoverLabel = createTypeString(tableChild, "h3")
  SetPixelPoint(hoverLabel, "TOPLEFT", tableHeading, "BOTTOMLEFT", 0, -16)
  hoverLabel:SetText("Hover rows")

  local tableY = -layout.padding - tableHeading:GetStringHeight() - layout.sectionGap - hoverLabel:GetStringHeight() - layout.gap
  local headerTexts = {"Character", "Role", "Score"}
  local restTexts = {"Liquidor", "Tank", "2840"}
  local hoverTexts = {"Calia", "Healer", "2715"}
  local selectedTexts = {"Toren", "DPS", "3120"}
  local selectedHoverTexts = {"Mara", "DPS", "3055"}
  ---@type LiqUI_DesignTableOptions
  local hoverTableOptions = {showBorder = true, hoverRows = true}
  local hoverTable, hoverInnerY, hoverInset = createTableShell(tableChild, tableY, hoverTableOptions)
  local tableHeader = Design.table.header
  local tableRowStyle = Design.table.row
  _, hoverInnerY = createTableRow(
    hoverTable,
    tableHeader,
    headerTexts,
    hoverInnerY,
    tableRowOptions(hoverTableOptions, true, hoverInset)
  )
  _, hoverInnerY = createTableRow(
    hoverTable,
    tableRowStyle,
    restTexts,
    hoverInnerY,
    tableRowOptions(hoverTableOptions, false, hoverInset)
  )
  local hoverRow
  hoverRow, hoverInnerY = createTableRow(
    hoverTable,
    tableRowStyle,
    hoverTexts,
    hoverInnerY,
    tableRowOptions(hoverTableOptions, false, hoverInset)
  )
  hoverRow.previewOver = true
  local selectedRow
  selectedRow, hoverInnerY = createTableRow(
    hoverTable,
    tableRowStyle,
    selectedTexts,
    hoverInnerY,
    tableRowOptions(hoverTableOptions, false, hoverInset)
  )
  selectedRow.selected = true
  local selectedHoverRow
  selectedHoverRow, hoverInnerY = createTableRow(
    hoverTable,
    tableRowStyle,
    selectedHoverTexts,
    hoverInnerY,
    tableRowOptions(hoverTableOptions, false, hoverInset)
  )
  selectedHoverRow.selected = true
  selectedHoverRow.previewOver = true
  tableY = closeTableShell(hoverTable, tableY, hoverInnerY, hoverInset)

  local stripeLabel = createTypeString(tableChild, "h3")
  SetPixelPoint(stripeLabel, "TOPLEFT", tableChild, "TOPLEFT", layout.padding, tableY - layout.sectionGap)
  stripeLabel:SetText("No hover")
  tableY = tableY - layout.sectionGap - stripeLabel:GetStringHeight() - layout.gap
  ---@type LiqUI_DesignTableOptions
  local restTableOptions = {showBorder = true, hoverRows = false}
  local restTable, restInnerY, restInset = createTableShell(tableChild, tableY, restTableOptions)
  _, restInnerY = createTableRow(
    restTable,
    tableHeader,
    headerTexts,
    restInnerY,
    tableRowOptions(restTableOptions, true, restInset)
  )
  for index = 1, #TABLE_STRIPE_ROWS do
    _, restInnerY = createTableRow(
      restTable,
      tableRowStyle,
      TABLE_STRIPE_ROWS[index],
      restInnerY,
      tableRowOptions(restTableOptions, false, restInset, index % 2 == 1)
    )
  end
  tableY = closeTableShell(restTable, tableY, restInnerY, restInset)
  tableChild:SetHeight(math.max(1, -tableY + layout.padding))
  tableScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

  ---@class LiqUI_DesignSandboxButtonsPage
  local buttonsPage = CreateFrame("Frame", nil, body)
  body.buttonsPage = buttonsPage
  buttonsPage:SetAllPoints()
  buttonsPage:Hide()

  local buttonsHeading = createTypeString(buttonsPage, "h1")
  buttonsPage.heading = buttonsHeading
  SetPixelPoint(buttonsHeading, "TOPLEFT", buttonsPage, "TOPLEFT", layout.padding, -layout.padding)
  buttonsHeading:SetText("Buttons")

  local buttonY = -layout.padding - buttonsHeading:GetStringHeight() - layout.sectionGap
  buttonY = layoutButtonStateRow(buttonsPage, Design.button.primary, "Primary", buttonY)
  buttonY = layoutButtonStateRow(buttonsPage, Design.button.secondary, "Secondary", buttonY)

  local pairLabel = createTypeString(buttonsPage, "h3")
  SetPixelPoint(pairLabel, "TOPLEFT", buttonsPage, "TOPLEFT", layout.padding, buttonY)
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
  SetPixelPoint(inputHeading, "TOPLEFT", inputPage, "TOPLEFT", layout.padding, -layout.padding)
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
  Design:SetPadding(scrollChild, layout.padding)
  ---@type LiqUI_DesignStackOptions
  local textStack = {
    gap = 8,
    onLayout = function()
      scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    end,
  }
  addTextSample(scrollChild, "h1", "h1 is the page title.", textStack)
  addTextSample(scrollChild, "title", "title is the window titlebar.", textStack)
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

  local menuRow = Design.menu.row
  local menuStep = menuRow.height + menuRow.gap
  local colorsRow = createMenuRow(menu, "Colors", "colors", -layout.padding)
  menu.colorsRow = colorsRow
  local windowRow = createMenuRow(menu, "Window", "window", -(layout.padding + menuStep))
  menu.windowRow = windowRow
  local tableRow = createMenuRow(menu, "Table", "table", -(layout.padding + menuStep * 2))
  menu.tableRow = tableRow
  local buttonsRow = createMenuRow(menu, "Buttons", "buttons", -(layout.padding + menuStep * 3))
  menu.buttonsRow = buttonsRow
  local inputRow = createMenuRow(menu, "Input", "input", -(layout.padding + menuStep * 4))
  menu.inputRow = inputRow
  local textRow = createMenuRow(menu, "Text", "text", -(layout.padding + menuStep * 5))
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
