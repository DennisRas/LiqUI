---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design
local Events = LiqUI.Events
local SetBackgroundColor = LiqUI.Utils.SetBackgroundColor
local SetPixelBackdrop = LiqUI.Utils.SetPixelBackdrop
local CreateScrollBox = LiqUI.Utils.CreateScrollBox
local BindScrollBoxMouseWheel = LiqUI.Utils.BindScrollBoxMouseWheel
local SetPixelPoint = PixelUtil.SetPoint
local SetPixelSize = PixelUtil.SetSize
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
local WINDOW_WIDTH = 880
local WINDOW_HEIGHT = 700
local TITLEBAR_HEIGHT = 32
local MENU_WIDTH = 180
local PADDING = 16
local MENU_ROW_HEIGHT = 24
local MENU_ROW_GAP = 4
local CONTROL_HEIGHT = 28
local CONTROL_GAP = 8
local SAMPLE_BUTTON_WIDTH = 100
local INPUT_WIDTH = 240
local INPUT_TEXT_INSET = 8
local TEXT_WIDTH = 600
local TEXT_SCROLL_BAR_WIDTH = 12
local SWATCH_SIZE = 40
local SWATCH_GAP = 8
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

---@param color ColorMixin
---@return number, number, number, number
local function colorRGBA(color)
  return color:GetRGBA()
end

local function setPixelInsetFill(region, fill)
  fill:ClearAllPoints()
  SetPixelPoint(fill, "TOPLEFT", region, "TOPLEFT", 1, -1, 1, 1)
  SetPixelPoint(fill, "BOTTOMRIGHT", region, "BOTTOMRIGHT", -1, 1, 1, 1)
end

---@param parent Frame
---@param typeId LiqUI_DesignTypeId
---@return FontString
local function createTypeString(parent, typeId)
  local style = Design.typography[typeId]
  local fontString = parent:CreateFontString(nil, "OVERLAY", style.fontObject)
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
  SetPixelSize(swatch, SWATCH_SIZE, SWATCH_SIZE)
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
  button:SetNormalFontObject("GameFontHighlight")
  button:SetHighlightFontObject("GameFontHighlight")
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
  }
  return state
end

---@param row LiqUI_DesignSandboxControl
local function paintControl(row)
  local scale = Design.scale
  local fill = Design:ResolveFill(row.controlKind, controlState(row))
  row.Fill:SetVertexColor(colorRGBA(fill))
  local textColor = scale.white
  if not row:IsEnabled() then
    textColor = scale.tint50
  end
  local fontString = row.GetFontString and row:GetFontString()
  if fontString then
    fontString:SetTextColor(colorRGBA(textColor))
  end
  if row.controlKind == "input" then
    row:SetTextColor(colorRGBA(textColor))
    local border = scale.shade50
    if row.focused then
      border = scale.primary
    end
    row:SetBackdropBorderColor(colorRGBA(border))
    local instructions = row.Instructions
    if instructions then
      instructions:SetTextColor(colorRGBA(scale.tint50))
      instructions:SetShown(row:GetText() == "")
    end
  end
end

---@param row LiqUI_DesignSandboxControl
---@param kind LiqUI_DesignControlKindId
local function setupControl(row, kind)
  row.controlKind = kind
  Mixin(row, ButtonStateBehaviorMixin)
  local fillLayer = "ARTWORK"
  if kind == "input" then
    fillLayer = "BACKGROUND"
  end
  local fill = row:CreateTexture(nil, fillLayer)
  fill:SetTexture(WHITE8X8)
  row.Fill = fill
  if kind == "input" then
    setPixelInsetFill(row, fill)
  else
    fill:SetAllPoints()
  end
  row:SetScript("OnEnter", row.OnEnter)
  row:SetScript("OnLeave", row.OnLeave)
  row:SetScript("OnMouseDown", row.OnMouseDown)
  row:SetScript("OnMouseUp", row.OnMouseUp)
  if kind ~= "input" then
    row:SetScript("OnEnable", row.OnEnable)
    row:SetScript("OnDisable", row.OnDisable)
  end
  row.OnButtonStateChanged = paintControl
  table.insert(controls, row)
end

---@param parent Frame
---@param kind LiqUI_DesignControlKindId
---@param text string
---@param width number
---@return LiqUI_DesignSandboxControl
local function createSampleButton(parent, kind, text, width)
  ---@class LiqUI_DesignSandboxControl
  local button = CreateFrame("Button", nil, parent)
  SetPixelSize(button, width, CONTROL_HEIGHT)
  setButtonLabel(button, text)
  setupControl(button, kind)
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
  SetPixelSize(input, INPUT_WIDTH, CONTROL_HEIGHT)
  input:SetAutoFocus(false)
  input:SetFontObject("GameFontHighlight")
  input:SetTextInsets(INPUT_TEXT_INSET, INPUT_TEXT_INSET, 0, 0)
  input:SetText(text or "")
  SetPixelBackdrop(input, 1, false)
  setupControl(input, "input")
  if placeholder then
    local instructions = input:CreateFontString(nil, "OVERLAY")
    instructions:SetFontObject("GameFontHighlight")
    instructions:SetJustifyH("LEFT")
    SetPixelPoint(instructions, "TOPLEFT", input, "TOPLEFT", INPUT_TEXT_INSET, 0)
    SetPixelPoint(instructions, "BOTTOMRIGHT", input, "BOTTOMRIGHT", -INPUT_TEXT_INSET, 0)
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

---@param pageId LiqUI_DesignSandboxPageId
local function selectPage(pageId)
  if not sandbox then
    return
  end
  sandbox.menu.colorsRow.selected = pageId == "colors"
  sandbox.menu.buttonsRow.selected = pageId == "buttons"
  sandbox.menu.inputRow.selected = pageId == "input"
  sandbox.menu.textRow.selected = pageId == "text"
  sandbox.body.colorsPage:SetShown(pageId == "colors")
  sandbox.body.buttonsPage:SetShown(pageId == "buttons")
  sandbox.body.inputPage:SetShown(pageId == "input")
  sandbox.body.textPage:SetShown(pageId == "text")
  paintControl(sandbox.menu.colorsRow)
  paintControl(sandbox.menu.buttonsRow)
  paintControl(sandbox.menu.inputRow)
  paintControl(sandbox.menu.textRow)
end

---@param parent Frame
---@param text string
---@param pageId LiqUI_DesignSandboxPageId
---@param yOffset number
---@return LiqUI_DesignSandboxControl
local function createMenuRow(parent, text, pageId, yOffset)
  ---@class LiqUI_DesignSandboxControl
  local row = CreateFrame("Button", nil, parent)
  SetPixelPoint(row, "TOPLEFT", parent, "TOPLEFT", PADDING, yOffset)
  SetPixelPoint(row, "TOPRIGHT", parent, "TOPRIGHT", -PADDING, yOffset)
  SetPixelHeight(row, MENU_ROW_HEIGHT)
  setButtonLabel(row, text)
  local label = row:GetFontString()
  label:ClearAllPoints()
  SetPixelPoint(label, "LEFT", row, "LEFT", 8, 0)
  label:SetJustifyH("LEFT")
  setupControl(row, "menuRow")
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
  SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", PADDING, yOffset)
  headingLabel:SetText(heading)

  local rowY = yOffset - 22
  for index = 1, #keys do
    local key = keys[index]
    local swatch = createSwatch(parent, source[key], key)
    SetPixelPoint(swatch, "TOPLEFT", parent, "TOPLEFT", PADDING + (index - 1) * (SWATCH_SIZE + SWATCH_GAP), rowY)
  end
  return rowY - SWATCH_SIZE - 22
end

---@param parent Frame
---@param kind LiqUI_DesignControlKindId
---@param heading string
---@param yOffset number
---@return number
local function layoutButtonStateRow(parent, kind, heading, yOffset)
  local headingLabel = createTypeString(parent, "h3")
  SetPixelPoint(headingLabel, "TOPLEFT", parent, "TOPLEFT", PADDING, yOffset)
  headingLabel:SetText(heading)

  local rest = createSampleButton(parent, kind, "Rest", SAMPLE_BUTTON_WIDTH)
  SetPixelPoint(rest, "TOPLEFT", headingLabel, "BOTTOMLEFT", 0, -6)

  local hover = createSampleButton(parent, kind, "Hover", SAMPLE_BUTTON_WIDTH)
  hover.previewOver = true
  SetPixelPoint(hover, "LEFT", rest, "RIGHT", CONTROL_GAP, 0)

  local pressed = createSampleButton(parent, kind, "Pressed", SAMPLE_BUTTON_WIDTH)
  pressed.previewDown = true
  SetPixelPoint(pressed, "LEFT", hover, "RIGHT", CONTROL_GAP, 0)

  local disabled = createSampleButton(parent, kind, "Disabled", SAMPLE_BUTTON_WIDTH)
  disabled:Disable()
  SetPixelPoint(disabled, "LEFT", pressed, "RIGHT", CONTROL_GAP, 0)

  return yOffset - 22 - CONTROL_HEIGHT - 24
end

---@param parent Frame
---@param typeId LiqUI_DesignTypeId
---@param text string
---@param yOffset number
---@return number
local function addTextSample(parent, typeId, text, yOffset)
  local style = Design.typography[typeId]
  local fontString = createTypeString(parent, typeId)
  SetPixelPoint(fontString, "TOPLEFT", parent, "TOPLEFT", PADDING, yOffset)
  fontString:SetJustifyH("LEFT")
  if style.wrap then
    fontString:SetWidth(TEXT_WIDTH)
  end
  fontString:SetText(text)
  return yOffset - fontString:GetStringHeight() - 8
end

local function applyPixelBackdrops()
  if not sandbox then
    return
  end
  SetPixelSize(sandbox, WINDOW_WIDTH, WINDOW_HEIGHT)
  SetPixelBackdrop(sandbox, 1, true)
  local inputPage = sandbox.body.inputPage
  SetPixelBackdrop(inputPage.nameInput, 1, false)
  SetPixelBackdrop(inputPage.emptyInput, 1, false)
  SetPixelBackdrop(inputPage.disabledInput, 1, false)
  setPixelInsetFill(inputPage.nameInput, inputPage.nameInput.Fill)
  setPixelInsetFill(inputPage.emptyInput, inputPage.emptyInput.Fill)
  setPixelInsetFill(inputPage.disabledInput, inputPage.disabledInput.Fill)
end

local function paintSandbox()
  if not sandbox then
    return
  end
  applyPixelBackdrops()
  local scale = Design.scale
  sandbox:SetBackdropColor(colorRGBA(scale.shade80))
  sandbox:SetBackdropBorderColor(colorRGBA(scale.shade50))
  SetBackgroundColor(sandbox.titlebar, scale.shade90)
  SetBackgroundColor(sandbox.menu, scale.shade80)
  SetBackgroundColor(sandbox.body, scale.shade70)
  sandbox.titlebar.CloseButton:GetFontString():SetTextColor(colorRGBA(scale.white))
  for index = 1, #controls do
    paintControl(controls[index])
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
  local textScrollBox = sandbox.body.textPage.scrollBox
  if textScrollBox then
    textScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end
end

local function buildSandbox()
  ---@class LiqUI_DesignSandbox
  local window = CreateFrame("Frame", "LiqUIDesignSandbox", UIParent, "BackdropTemplate")
  sandbox = window
  SetPixelSize(window, WINDOW_WIDTH, WINDOW_HEIGHT)
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
  SetPixelHeight(titlebar, TITLEBAR_HEIGHT)
  titlebar:EnableMouse(true)
  titlebar:RegisterForDrag("LeftButton")
  titlebar:SetScript("OnDragStart", function()
    window:StartMoving()
  end)
  titlebar:SetScript("OnDragStop", function()
    window:StopMovingOrSizing()
    savePoint()
  end)

  local title = createTypeString(titlebar, "h2")
  titlebar.title = title
  SetPixelPoint(title, "LEFT", titlebar, "LEFT", 12, 0)
  title:SetText("LiqUI Design")

  local closeButton = CreateFrame("Button", nil, titlebar)
  titlebar.CloseButton = closeButton
  SetPixelSize(closeButton, TITLEBAR_HEIGHT, TITLEBAR_HEIGHT)
  SetPixelPoint(closeButton, "RIGHT", titlebar, "RIGHT", 0, 0)
  setButtonLabel(closeButton, "X")
  closeButton:SetScript("OnClick", function()
    window:Hide()
  end)

  ---@class LiqUI_DesignSandboxMenu
  local menu = CreateFrame("Frame", nil, window)
  window.menu = menu
  SetPixelPoint(menu, "TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  SetPixelPoint(menu, "BOTTOMLEFT", window, "BOTTOMLEFT", 1, 1, 1, 1)
  SetPixelWidth(menu, MENU_WIDTH)

  ---@class LiqUI_DesignSandboxBody
  local body = CreateFrame("Frame", nil, window)
  window.body = body
  SetPixelPoint(body, "TOPLEFT", titlebar, "BOTTOMLEFT", MENU_WIDTH, 0)
  SetPixelPoint(body, "BOTTOMRIGHT", window, "BOTTOMRIGHT", -1, 1, 1, 1)

  ---@class LiqUI_DesignSandboxColorsPage
  local colorsPage = CreateFrame("Frame", nil, body)
  body.colorsPage = colorsPage
  colorsPage:SetAllPoints()

  local primaryLabel = createTypeString(colorsPage, "h1")
  colorsPage.primaryLabel = primaryLabel
  SetPixelPoint(primaryLabel, "TOPLEFT", colorsPage, "TOPLEFT", PADDING, -PADDING)

  local primarySwatch = createSwatch(colorsPage, Design.scale.primary, "Click to change", openPrimaryPicker)
  colorsPage.primarySwatch = primarySwatch
  SetPixelPoint(primarySwatch, "TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -8)
  SetPixelSize(primarySwatch, 72, 36)

  local yOffset = -PADDING - 90
  yOffset = layoutSwatchRow(colorsPage, TINT_KEYS, Design.scale, yOffset, "Tints  (toward white)")
  layoutSwatchRow(colorsPage, SHADE_KEYS, Design.scale, yOffset, "Shades  (toward black)")

  ---@class LiqUI_DesignSandboxButtonsPage
  local buttonsPage = CreateFrame("Frame", nil, body)
  body.buttonsPage = buttonsPage
  buttonsPage:SetAllPoints()
  buttonsPage:Hide()

  local buttonsHeading = createTypeString(buttonsPage, "h1")
  buttonsPage.heading = buttonsHeading
  SetPixelPoint(buttonsHeading, "TOPLEFT", buttonsPage, "TOPLEFT", PADDING, -PADDING)
  buttonsHeading:SetText("Buttons")

  local buttonY = -PADDING - buttonsHeading:GetStringHeight() - 16
  buttonY = layoutButtonStateRow(buttonsPage, "buttonPrimary", "Primary", buttonY)
  buttonY = layoutButtonStateRow(buttonsPage, "buttonSecondary", "Secondary", buttonY)

  local pairLabel = createTypeString(buttonsPage, "h3")
  SetPixelPoint(pairLabel, "TOPLEFT", buttonsPage, "TOPLEFT", PADDING, buttonY)
  pairLabel:SetText("Save and Cancel")

  local saveButton = createSampleButton(buttonsPage, "buttonPrimary", "Save", SAMPLE_BUTTON_WIDTH)
  SetPixelPoint(saveButton, "TOPLEFT", pairLabel, "BOTTOMLEFT", 0, -6)
  local cancelButton = createSampleButton(buttonsPage, "buttonSecondary", "Cancel", SAMPLE_BUTTON_WIDTH)
  SetPixelPoint(cancelButton, "LEFT", saveButton, "RIGHT", CONTROL_GAP, 0)

  ---@class LiqUI_DesignSandboxInputPage
  local inputPage = CreateFrame("Frame", nil, body)
  body.inputPage = inputPage
  inputPage:SetAllPoints()
  inputPage:Hide()

  local inputHeading = createTypeString(inputPage, "h1")
  inputPage.heading = inputHeading
  SetPixelPoint(inputHeading, "TOPLEFT", inputPage, "TOPLEFT", PADDING, -PADDING)
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
  local scrollBoxOptions = {barWidth = TEXT_SCROLL_BAR_WIDTH}
  local scrollBox = CreateScrollBox(textPage, nil, scrollBoxOptions)
  textPage.scrollBox = scrollBox
  SetPixelPoint(scrollBox, "TOPLEFT", textPage, "TOPLEFT", 0, 0)
  SetPixelPoint(scrollBox, "BOTTOMRIGHT", textPage, "BOTTOMRIGHT", -TEXT_SCROLL_BAR_WIDTH, 0)
  local scrollChild = scrollBox.scrollChild
  BindScrollBoxMouseWheel(textPage, scrollBox)

  local textY = -PADDING
  textY = addTextSample(scrollChild, "h1", "h1 is the page title.", textY)
  textY = addTextSample(
    scrollChild,
    "p",
    "p is body copy. It wraps inside the content width. The window titlebar uses h2.",
    textY
  )
  textY = addTextSample(scrollChild, "p", LOREM_BLOCK, textY)
  textY = addTextSample(scrollChild, "h2", "h2 is a section heading.", textY)
  textY = addTextSample(scrollChild, "p", LOREM_BLOCK, textY)
  textY = addTextSample(scrollChild, "p", LOREM_PARAGRAPH, textY)
  textY = addTextSample(scrollChild, "h3", "h3 is a subsection heading.", textY)
  textY = addTextSample(scrollChild, "p", LOREM_BLOCK, textY)
  textY = addTextSample(scrollChild, "label", "label is a field caption.", textY)
  textY = addTextSample(scrollChild, "p", LOREM_PARAGRAPH_TWO, textY)
  textY = addTextSample(scrollChild, "h2", "Another section heading.", textY)
  textY = addTextSample(scrollChild, "p", LOREM_BLOCK, textY)
  textY = addTextSample(scrollChild, "h3", "Another subsection heading.", textY)
  textY = addTextSample(scrollChild, "p", LOREM_BLOCK, textY)
  scrollChild:SetHeight(math.max(1, -textY + PADDING))
  scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

  local colorsRow = createMenuRow(menu, "Colors", "colors", -PADDING)
  menu.colorsRow = colorsRow
  local buttonsRow = createMenuRow(menu, "Buttons", "buttons", -(PADDING + MENU_ROW_HEIGHT + MENU_ROW_GAP))
  menu.buttonsRow = buttonsRow
  local inputRow = createMenuRow(menu, "Input", "input", -(PADDING + (MENU_ROW_HEIGHT + MENU_ROW_GAP) * 2))
  menu.inputRow = inputRow
  local textRow = createMenuRow(menu, "Text", "text", -(PADDING + (MENU_ROW_HEIGHT + MENU_ROW_GAP) * 3))
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
