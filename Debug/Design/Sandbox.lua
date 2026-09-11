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
local WINDOW_HEIGHT = 640
local TITLEBAR_HEIGHT = 32
local MENU_WIDTH = 180
local PADDING = 16
local SWATCH_SIZE = 40
local SWATCH_GAP = 8
local TINT_KEYS = {"tint10", "tint20", "tint30", "tint40", "tint50", "tint60", "tint70", "tint80", "tint90"}
local SHADE_KEYS = {"shade10", "shade20", "shade30", "shade40", "shade50", "shade60", "shade70", "shade80", "shade90"}
local TOKEN_KEYS = {"surface", "surfaceRaised", "border", "accent", "accentHover", "accentPressed", "text", "textMuted"}

---@type LiqUI_DesignSandbox?
local sandbox
---@type LiqUI_DesignColorBinding[]
local colorBindings = {}
---@type FontString[]
local mutedLabels = {}

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
  table.insert(mutedLabels, label)

  if onClick then
    swatch:SetScript("OnClick", onClick)
  end
  return swatch, label
end

local function paintSandbox()
  if not sandbox then
    return
  end
  local tokens = Design.tokens
  sandbox:SetBackdropColor(colorRGBA(tokens.surface))
  sandbox:SetBackdropBorderColor(colorRGBA(tokens.border))
  SetBackgroundColor(sandbox.titlebar, tokens.surfaceRaised)
  SetBackgroundColor(sandbox.menu, tokens.surfaceRaised)
  sandbox.titlebar.title:SetTextColor(colorRGBA(tokens.text))
  sandbox.titlebar.CloseButton:GetFontString():SetTextColor(colorRGBA(tokens.text))
  sandbox.menu.colorsRow:SetBackdropColor(colorRGBA(tokens.accent))
  sandbox.menu.colorsRow:GetFontString():SetTextColor(colorRGBA(tokens.text))
  sandbox.body.primaryLabel:SetTextColor(colorRGBA(tokens.text))
  sandbox.body.primaryLabel:SetText("Primary  #" .. Design.scale.primary:GenerateHexColorNoAlpha())
  for index = 1, #colorBindings do
    local binding = colorBindings[index]
    binding.texture:SetColorTexture(colorRGBA(binding.color))
  end
  for index = 1, #mutedLabels do
    mutedLabels[index]:SetTextColor(colorRGBA(tokens.textMuted))
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

---@param parent Frame
---@param keys string[]
---@param source table
---@param yOffset number
---@param heading string
---@return number
local function layoutSwatchRow(parent, keys, source, yOffset, heading)
  local headingLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  headingLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
  headingLabel:SetText(heading)
  table.insert(mutedLabels, headingLabel)

  local rowY = yOffset - 22
  for index = 1, #keys do
    local key = keys[index]
    local swatch = createSwatch(parent, source[key], key)
    swatch:SetPoint("TOPLEFT", parent, "TOPLEFT", (index - 1) * (SWATCH_SIZE + SWATCH_GAP), rowY)
  end
  return rowY - SWATCH_SIZE - 22
end

---@param parent Frame
---@param yOffset number
local function layoutRoleList(parent, yOffset)
  local headingLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  headingLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
  headingLabel:SetText("Roles  (what chrome reads)")
  table.insert(mutedLabels, headingLabel)

  local rowY = yOffset - 28
  for index = 1, #TOKEN_KEYS do
    local key = TOKEN_KEYS[index]
    local scaleKey = Design.tokenScaleKeys[key]
    local swatch, label = createSwatch(parent, Design.tokens[key], key .. "  " .. scaleKey)
    swatch:SetSize(24, 24)
    swatch:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, rowY)
    label:ClearAllPoints()
    label:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    rowY = rowY - 28
  end
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
    bgFile = "Interface/BUTTONS/WHITE8X8",
    edgeFile = "Interface/BUTTONS/WHITE8X8",
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

  local colorsRow = CreateFrame("Button", nil, menu, "BackdropTemplate")
  menu.colorsRow = colorsRow
  colorsRow:SetPoint("TOPLEFT", PADDING, -PADDING)
  colorsRow:SetPoint("TOPRIGHT", -PADDING, -PADDING)
  colorsRow:SetHeight(24)
  colorsRow:SetBackdrop({
    bgFile = "Interface/BUTTONS/WHITE8X8",
  })
  setButtonLabel(colorsRow, "Colors")
  local colorsLabel = colorsRow:GetFontString()
  colorsLabel:ClearAllPoints()
  colorsLabel:SetPoint("LEFT", 8, 0)
  colorsLabel:SetJustifyH("LEFT")

  ---@class LiqUI_DesignSandboxBody
  local body = CreateFrame("Frame", nil, window)
  window.body = body
  body:SetPoint("TOPLEFT", titlebar, "BOTTOMLEFT", MENU_WIDTH, 0)
  body:SetPoint("BOTTOMRIGHT", -1, 1)

  local primaryLabel = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  body.primaryLabel = primaryLabel
  primaryLabel:SetPoint("TOPLEFT", PADDING, -PADDING)

  local primarySwatch = createSwatch(body, Design.scale.primary, "Click to change", openPrimaryPicker)
  body.primarySwatch = primarySwatch
  primarySwatch:SetPoint("TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -8)
  primarySwatch:SetSize(72, 36)

  local yOffset = -PADDING - 90
  yOffset = layoutSwatchRow(body, TINT_KEYS, Design.scale, yOffset, "Tints  (toward white)")
  yOffset = layoutSwatchRow(body, SHADE_KEYS, Design.scale, yOffset, "Shades  (toward black)")
  layoutRoleList(body, yOffset)

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
