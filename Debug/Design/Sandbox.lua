---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design
local Events = LiqUI.Events
local SetBackgroundColor = LiqUI.Utils.SetBackgroundColor
local WINDOW_WIDTH = 880
local WINDOW_HEIGHT = 700
local TITLEBAR_HEIGHT = 32
local MENU_WIDTH = 180
local PADDING = 16
local MENU_ROW_HEIGHT = 24
local MENU_ROW_GAP = 4
local INPUT_WIDTH = 240
local INPUT_HEIGHT = 24
local SWATCH_SIZE = 40
local SWATCH_GAP = 8
local TINT_KEYS = {"tint10", "tint20", "tint30", "tint40", "tint50", "tint60", "tint70", "tint80", "tint90"}
local SHADE_KEYS = {"shade10", "shade20", "shade30", "shade40", "shade50", "shade60", "shade70", "shade80", "shade90"}
local WHITE8X8 = "Interface/BUTTONS/WHITE8X8"

---@type LiqUI_DesignSandbox?
local sandbox
---@type LiqUI_DesignColorBinding[]
local colorBindings = {}
---@type FontString[]
local labels = {}

---@param color ColorMixin
---@return number, number, number, number
local function colorRGBA(color)
  return color:GetRGBA()
end

---@param parent Frame
---@param color ColorMixin
---@param labelText string
---@param onClick function?
---@return Frame, FontString
local function createSwatch(parent, color, labelText, onClick)
  local swatch = CreateFrame("Button", nil, parent)
  swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
  local fill = swatch:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints()
  fill:SetColorTexture(colorRGBA(color))
  ---@type LiqUI_DesignColorBinding
  local binding = {texture = fill, color = color}
  table.insert(colorBindings, binding)

  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  label:SetPoint("TOP", swatch, "BOTTOM", 0, -2)
  label:SetText(labelText)
  table.insert(labels, label)

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
    over = row:IsOver() and true or false,
    down = row:IsDown() and true or false,
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
  local textColor = scale.tint90
  if not row:IsEnabled() then
    textColor = scale.tint60
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
    fill:SetPoint("TOPLEFT", 1, -1)
    fill:SetPoint("BOTTOMRIGHT", -1, 1)
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
end

---@param parent Frame
---@param kind LiqUI_DesignControlKindId
---@param text string
---@param width number
---@return LiqUI_DesignSandboxControl
local function createSampleButton(parent, kind, text, width)
  ---@class LiqUI_DesignSandboxControl
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(width, 24)
  setButtonLabel(button, text)
  setupControl(button, kind)
  return button
end

---@param parent Frame
---@param text string
---@param enabled boolean?
---@return LiqUI_DesignSandboxControl
local function createSampleInput(parent, text, enabled)
  ---@class LiqUI_DesignSandboxControl
  local input = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
  input:SetSize(INPUT_WIDTH, INPUT_HEIGHT)
  input:SetAutoFocus(false)
  input:SetFontObject("GameFontHighlight")
  input:SetTextInsets(8, 8, 0, 0)
  input:SetText(text or "")
  input:SetBackdrop({
    edgeFile = WHITE8X8,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
  })
  setupControl(input, "input")
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
  sandbox.menu.inputRow.selected = pageId == "input"
  sandbox.body.colorsPage:SetShown(pageId == "colors")
  sandbox.body.inputPage:SetShown(pageId == "input")
  paintControl(sandbox.menu.colorsRow)
  paintControl(sandbox.menu.inputRow)
end

---@param parent Frame
---@param text string
---@param pageId LiqUI_DesignSandboxPageId
---@param yOffset number
---@return LiqUI_DesignSandboxControl
local function createMenuRow(parent, text, pageId, yOffset)
  ---@class LiqUI_DesignSandboxControl
  local row = CreateFrame("Button", nil, parent)
  row:SetPoint("TOPLEFT", PADDING, yOffset)
  row:SetPoint("TOPRIGHT", -PADDING, yOffset)
  row:SetHeight(MENU_ROW_HEIGHT)
  setButtonLabel(row, text)
  local label = row:GetFontString()
  label:ClearAllPoints()
  label:SetPoint("LEFT", 8, 0)
  label:SetJustifyH("LEFT")
  setupControl(row, "menuRow")
  row:SetScript("OnClick", function()
    selectPage(pageId)
  end)
  return row
end

local function paintSandbox()
  if not sandbox then
    return
  end
  local scale = Design.scale
  sandbox:SetBackdropColor(colorRGBA(scale.shade80))
  sandbox:SetBackdropBorderColor(colorRGBA(scale.shade50))
  SetBackgroundColor(sandbox.titlebar, scale.shade80)
  SetBackgroundColor(sandbox.menu, scale.shade80)
  SetBackgroundColor(sandbox.body, scale.shade70)
  sandbox.titlebar.title:SetTextColor(colorRGBA(scale.tint90))
  sandbox.titlebar.CloseButton:GetFontString():SetTextColor(colorRGBA(scale.tint90))
  paintControl(sandbox.menu.colorsRow)
  paintControl(sandbox.menu.inputRow)
  paintControl(sandbox.body.colorsPage.primaryButton)
  paintControl(sandbox.body.colorsPage.secondaryButton)
  paintControl(sandbox.body.inputPage.nameInput)
  paintControl(sandbox.body.inputPage.emptyInput)
  paintControl(sandbox.body.inputPage.disabledInput)
  sandbox.body.colorsPage.primaryLabel:SetTextColor(colorRGBA(scale.tint90))
  sandbox.body.colorsPage.primaryLabel:SetText("Primary  #" .. scale.primary:GenerateHexColorNoAlpha())
  sandbox.body.inputPage.heading:SetTextColor(colorRGBA(scale.tint90))
  for index = 1, #colorBindings do
    local binding = colorBindings[index]
    binding.texture:SetColorTexture(colorRGBA(binding.color))
  end
  for index = 1, #labels do
    labels[index]:SetTextColor(colorRGBA(scale.tint90))
  end
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
    sandbox:SetPoint(point[1], UIParent, point[2], point[3], point[4])
    return
  end
  sandbox:SetPoint("CENTER")
end

---@param parent Frame
---@param keys string[]
---@param source table
---@param yOffset number
---@param heading string
---@return number
local function layoutSwatchRow(parent, keys, source, yOffset, heading)
  local headingLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  headingLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING, yOffset)
  headingLabel:SetText(heading)
  table.insert(labels, headingLabel)

  local rowY = yOffset - 22
  for index = 1, #keys do
    local key = keys[index]
    local swatch = createSwatch(parent, source[key], key)
    swatch:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING + (index - 1) * (SWATCH_SIZE + SWATCH_GAP), rowY)
  end
  return rowY - SWATCH_SIZE - 22
end

local function buildSandbox()
  ---@class LiqUI_DesignSandbox
  local window = CreateFrame("Frame", "LiqUIDesignSandbox", UIParent, "BackdropTemplate")
  sandbox = window
  window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
  window:SetFrameStrata("HIGH")
  window:SetClampedToScreen(true)
  window:SetMovable(true)
  window:EnableMouse(true)
  window:SetBackdrop({
    bgFile = WHITE8X8,
    edgeFile = WHITE8X8,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1},
  })
  applySavedPoint()

  ---@class LiqUI_DesignSandboxTitlebar
  local titlebar = CreateFrame("Frame", nil, window)
  window.titlebar = titlebar
  titlebar:SetPoint("TOPLEFT", 1, -1)
  titlebar:SetPoint("TOPRIGHT", -1, -1)
  titlebar:SetHeight(TITLEBAR_HEIGHT)
  titlebar:EnableMouse(true)
  titlebar:RegisterForDrag("LeftButton")
  titlebar:SetScript("OnDragStart", function()
    window:StartMoving()
  end)
  titlebar:SetScript("OnDragStop", function()
    window:StopMovingOrSizing()
    savePoint()
  end)

  local title = titlebar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  titlebar.title = title
  title:SetPoint("LEFT", 12, 0)
  title:SetText("LiqUI Design")

  local closeButton = CreateFrame("Button", nil, titlebar)
  titlebar.CloseButton = closeButton
  closeButton:SetSize(TITLEBAR_HEIGHT, TITLEBAR_HEIGHT)
  closeButton:SetPoint("RIGHT", 0, 0)
  setButtonLabel(closeButton, "X")
  closeButton:SetScript("OnClick", function()
    window:Hide()
  end)

  ---@class LiqUI_DesignSandboxMenu
  local menu = CreateFrame("Frame", nil, window)
  window.menu = menu
  menu:SetPoint("TOPLEFT", titlebar, "BOTTOMLEFT", 0, 0)
  menu:SetPoint("BOTTOMLEFT", 1, 1)
  menu:SetWidth(MENU_WIDTH)

  ---@class LiqUI_DesignSandboxBody
  local body = CreateFrame("Frame", nil, window)
  window.body = body
  body:SetPoint("TOPLEFT", titlebar, "BOTTOMLEFT", MENU_WIDTH, 0)
  body:SetPoint("BOTTOMRIGHT", -1, 1)

  ---@class LiqUI_DesignSandboxColorsPage
  local colorsPage = CreateFrame("Frame", nil, body)
  body.colorsPage = colorsPage
  colorsPage:SetAllPoints()

  local primaryLabel = colorsPage:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  colorsPage.primaryLabel = primaryLabel
  primaryLabel:SetPoint("TOPLEFT", PADDING, -PADDING)

  local primarySwatch = createSwatch(colorsPage, Design.scale.primary, "Click to change", openPrimaryPicker)
  colorsPage.primarySwatch = primarySwatch
  primarySwatch:SetPoint("TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -8)
  primarySwatch:SetSize(72, 36)

  local primaryButton = createSampleButton(colorsPage, "buttonPrimary", "Save", 88)
  colorsPage.primaryButton = primaryButton
  primaryButton:SetPoint("TOPLEFT", primarySwatch, "BOTTOMLEFT", 0, -20)

  local secondaryButton = createSampleButton(colorsPage, "buttonSecondary", "Cancel", 88)
  colorsPage.secondaryButton = secondaryButton
  secondaryButton:SetPoint("LEFT", primaryButton, "RIGHT", 8, 0)

  local yOffset = -PADDING - 150
  yOffset = layoutSwatchRow(colorsPage, TINT_KEYS, Design.scale, yOffset, "Tints  (toward white)")
  layoutSwatchRow(colorsPage, SHADE_KEYS, Design.scale, yOffset, "Shades  (toward black)")

  ---@class LiqUI_DesignSandboxInputPage
  local inputPage = CreateFrame("Frame", nil, body)
  body.inputPage = inputPage
  inputPage:SetAllPoints()
  inputPage:Hide()

  local inputHeading = inputPage:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  inputPage.heading = inputHeading
  inputHeading:SetPoint("TOPLEFT", PADDING, -PADDING)
  inputHeading:SetText("Input")

  local nameLabel = inputPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  nameLabel:SetPoint("TOPLEFT", inputHeading, "BOTTOMLEFT", 0, -16)
  nameLabel:SetText("With text")
  table.insert(labels, nameLabel)

  local nameInput = createSampleInput(inputPage, "Player name", true)
  inputPage.nameInput = nameInput
  nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -6)

  local emptyLabel = inputPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  emptyLabel:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -16)
  emptyLabel:SetText("Empty")
  table.insert(labels, emptyLabel)

  local emptyInput = createSampleInput(inputPage, "", true)
  inputPage.emptyInput = emptyInput
  emptyInput:SetPoint("TOPLEFT", emptyLabel, "BOTTOMLEFT", 0, -6)

  local disabledLabel = inputPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  disabledLabel:SetPoint("TOPLEFT", emptyInput, "BOTTOMLEFT", 0, -16)
  disabledLabel:SetText("Disabled")
  table.insert(labels, disabledLabel)

  local disabledInput = createSampleInput(inputPage, "Cannot edit", false)
  inputPage.disabledInput = disabledInput
  disabledInput:SetPoint("TOPLEFT", disabledLabel, "BOTTOMLEFT", 0, -6)

  local colorsRow = createMenuRow(menu, "Colors", "colors", -PADDING)
  menu.colorsRow = colorsRow
  local inputRow = createMenuRow(menu, "Input", "input", -(PADDING + MENU_ROW_HEIGHT + MENU_ROW_GAP))
  menu.inputRow = inputRow
  selectPage("colors")

  paintSandbox()
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
