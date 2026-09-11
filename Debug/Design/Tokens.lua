---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

LiqUI.Design = LiqUI.Design or {
  scale = {},
  tokens = {},
  listeners = {},
  tokenScaleKeys = {
    surface = "shade80",
    surfaceRaised = "shade70",
    border = "shade50",
    accent = "primary",
    accentHover = "tint10",
    accentPressed = "shade10",
    text = "tint90",
    textMuted = "tint60",
  },
}

---@class LiqUI_Design
local Design = LiqUI.Design
local STEPS = {10, 20, 30, 40, 50, 60, 70, 80, 90}
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

---@param r number
---@param g number
---@param b number
local function rebuild(r, g, b)
  local scale = Design.scale
  scale.primary = ensureColor(scale.primary)
  scale.primary:SetRGB(r, g, b)

  for index = 1, #STEPS do
    local step = STEPS[index]
    local amount = step / 100
    local tintKey = "tint" .. step
    local shadeKey = "shade" .. step
    local tint = ensureColor(scale[tintKey])
    local shade = ensureColor(scale[shadeKey])
    tint:SetRGB(mixChannel(r, 1, amount), mixChannel(g, 1, amount), mixChannel(b, 1, amount))
    shade:SetRGB(mixChannel(r, 0, amount), mixChannel(g, 0, amount), mixChannel(b, 0, amount))
    scale[tintKey] = tint
    scale[shadeKey] = shade
  end

  LiqUI.Utils.TableForEach(Design.tokenScaleKeys, function(scaleKey, tokenKey)
    local source = scale[scaleKey]
    local token = ensureColor(Design.tokens[tokenKey])
    token:SetRGBA(source:GetRGBA())
    Design.tokens[tokenKey] = token
  end)
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
