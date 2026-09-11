---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

LiqUI.Design = LiqUI.Design or {
  scale = {},
  listeners = {},
  typography = {
    h1 = {fontObject = "GameFontHighlightLarge", color = "white"},
    h2 = {fontObject = "SystemFont_Med3", color = "white"},
    h3 = {fontObject = "GameFontHighlight", color = "white"},
    p = {fontObject = "GameFontHighlight", color = "white", wrap = true},
    label = {fontObject = "GameFontHighlightSmall", color = "white"},
  },
  controlKinds = {
    menuRow = {
      rest = "shade80",
      hover = "shade50",
      pressed = "shade10",
      selected = "primary",
      selectedHover = "tint10",
      disabled = "shade80",
    },
    buttonPrimary = {
      rest = "primary",
      hover = "tint5",
      pressed = "shade10",
      disabled = "shade80",
    },
    buttonSecondary = {
      rest = "shade50",
      hover = "shade40",
      pressed = "shade60",
      disabled = "shade80",
    },
    input = {
      rest = "shade80",
      hover = "shade70",
      pressed = "shade80",
      focused = "shade80",
      disabled = "shade90",
    },
  },
}

---@class LiqUI_Design
local Design = LiqUI.Design
local TINT_STEPS = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50}
local SHADE_STEPS = {10, 20, 30, 40, 50, 60, 70, 80, 90}
local DEFAULT_PRIMARY = CreateColorFromHexString("FF1A4A6B")

---@return LiqUI_DesignDB
local function getStore()
  LiqUIDB = LiqUIDB or {}
  if not LiqUIDB.design then
    local r, g, b = DEFAULT_PRIMARY:GetRGB()
    ---@type LiqUI_DesignDB
    local designDB = {
      primary = {r = r, g = g, b = b},
    }
    LiqUIDB.design = designDB
  end
  return LiqUIDB.design
end

---@param from number
---@param toward number
---@param amount number
---@return number
local function mixChannel(from, toward, amount)
  return from + (toward - from) * amount
end

---@param color ColorMixin?
---@return ColorMixin
local function ensureColor(color)
  if color then
    return color
  end
  return CreateColor(0, 0, 0, 1)
end

---@param scale LiqUI_DesignScale
---@param r number
---@param g number
---@param b number
---@param steps number[]
---@param prefix string
---@param towardR number
---@param towardG number
---@param towardB number
local function rebuildSteps(scale, r, g, b, steps, prefix, towardR, towardG, towardB)
  for index = 1, #steps do
    local step = steps[index]
    local amount = step / 100
    local key = prefix .. step
    local color = ensureColor(scale[key])
    color:SetRGB(mixChannel(r, towardR, amount), mixChannel(g, towardG, amount), mixChannel(b, towardB, amount))
    scale[key] = color
  end
end

---@param r number
---@param g number
---@param b number
local function rebuild(r, g, b)
  local scale = Design.scale
  scale.primary = ensureColor(scale.primary)
  scale.primary:SetRGB(r, g, b)
  scale.white = ensureColor(scale.white)
  scale.white:SetRGB(1, 1, 1)
  rebuildSteps(scale, r, g, b, TINT_STEPS, "tint", 1, 1, 1)
  rebuildSteps(scale, r, g, b, SHADE_STEPS, "shade", 0, 0, 0)
end

local function notify()
  local listeners = Design.listeners
  for index = 1, #listeners do
    listeners[index]()
  end
end

---@param r number
---@param g number
---@param b number
function Design:SetPrimary(r, g, b)
  local store = getStore()
  store.primary.r = r
  store.primary.g = g
  store.primary.b = b
  rebuild(r, g, b)
  notify()
end

---@return number, number, number
function Design:GetPrimary()
  local primary = self.scale.primary
  return primary:GetRGB()
end

---@param listener function
function Design:RegisterOnChanged(listener)
  table.insert(self.listeners, listener)
end

---@return LiqUI_DesignDB
function Design:GetDB()
  return getStore()
end

---@param kind LiqUI_DesignControlKindId
---@param state LiqUI_DesignControlState
---@return ColorMixin
function Design:ResolveFill(kind, state)
  local map = self.controlKinds[kind]
  local key = map.rest
  if not state.enabled then
    key = map.disabled or map.rest
  elseif state.down then
    key = map.pressed
  elseif state.focused and map.focused then
    key = map.focused
  elseif state.selected and state.over then
    key = map.selectedHover or map.hover
  elseif state.over then
    key = map.hover
  elseif state.selected and map.selected then
    key = map.selected
  end
  return self.scale[key]
end

---@param fontString FontString
---@param typeId LiqUI_DesignTypeId
function Design:ApplyType(fontString, typeId)
  local style = self.typography[typeId]
  fontString:SetFontObject(style.fontObject)
  local color = self.scale[style.color]
  fontString:SetTextColor(color:GetRGBA())
  if style.wrap then
    fontString:SetWordWrap(true)
  else
    fontString:SetWordWrap(false)
  end
end
