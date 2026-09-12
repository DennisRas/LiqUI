---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design or {
  scale = {},
  listeners = {},
  typography = {
    h1 = {size = 24, spacing = 4, color = "white"},
    h2 = {size = 18, spacing = 3, color = "white"},
    h3 = {size = 15, spacing = 2, color = "white"},
    title = {size = 13, spacing = 0, color = "white"},
    p = {size = 13, spacing = 8, wrap = true, color = "white", file = "Fonts\\ARIALN.TTF"},
    label = {size = 12, spacing = 0, color = "white"},
  },
  layout = {
    padding = 16,
    gap = 8,
    sectionGap = 16,
    scrollBar = 12,
    swatchSize = 40,
    swatchGap = 8,
  },
  window = {
    width = 880,
    height = 700,
    titlebarHeight = 32,
    menuWidth = 180,
    overlayAlpha = 0.85,
    sampleHeight = 168,
    borderPixels = 1,
    fill = "shade80",
    border = "shade50",
    titlebar = "shade90",
    menu = "shade80",
    body = "shade70",
  },
  menu = {
    row = {
      rest = "shade80",
      selected = "primary",
      disabled = "shade80",
      height = 32,
      gap = 2,
      hover = true,
      press = true,
      hoverWash = 0.1,
      pressWash = 0.25,
      borderPixels = 0,
    },
  },
  titlebar = {
    button = {
      rest = "shade90",
      disabled = "shade90",
      height = 32,
      width = 32,
      hover = true,
      press = true,
      hoverWash = 0.1,
      pressWash = 0.25,
      borderPixels = 0,
    },
  },
  button = {
    primary = {
      rest = "primary",
      disabled = "shade80",
      height = 28,
      width = 100,
      hover = true,
      press = true,
      hoverWash = 0.1,
      pressWash = 0.25,
      borderPixels = 2,
      borderTint = 35,
      activeBorder = true,
    },
    secondary = {
      rest = "shade50",
      disabled = "shade80",
      height = 28,
      width = 100,
      hover = true,
      press = true,
      hoverWash = 0.1,
      pressWash = 0.25,
      borderPixels = 2,
      borderTint = 35,
      activeBorder = true,
    },
  },
  input = {
    rest = "shade80",
    disabled = "shade90",
    height = 28,
    hover = true,
    press = false,
    hoverWash = 0.1,
    borderPixels = 1,
    borderRest = "shade50",
    borderFocus = "primary",
    fillLayer = "BACKGROUND",
    textInset = 8,
  },
  table = {
    fill = "shade80",
    border = "shade50",
    borderPixels = 1,
    cellPad = 8,
    rowHeight = 28,
    showBorder = true,
    hoverRows = false,
    headerHover = false,
    header = {
      rest = "shade90",
      disabled = "shade90",
      hover = false,
      press = false,
      hoverWash = 0.1,
      borderPixels = 0,
    },
    row = {
      rest = "shade80",
      alt = "shade70",
      selected = "primary",
      disabled = "shade80",
      hover = false,
      press = true,
      hoverWash = 0.1,
      pressWash = 0.25,
      borderPixels = 0,
    },
  },
}
LiqUI.Design = Design
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
local SetPixelPoint = PixelUtil.SetPoint
local TYPE_IDS = {"h1", "h2", "h3", "title", "p", "label"}
local DEFAULT_FONT_FILE = "Fonts\\FRIZQT__.TTF"
local DEFAULT_FONT_FLAGS = ""
---@type table<Frame, LiqUI_DesignSizeBinding[]>
local sizeBindingsByParent = {}
---@type table<Frame, number>
local paddingByParent = {}
---@type table<Frame, LiqUI_DesignStack>
local stacksByParent = {}
---@type LiqUI_DesignStack[]
local stackList = {}
---@type table<Frame, boolean>
local stackLayoutQueued = {}
---@type table<Frame, boolean>
local stackLayoutActive = {}
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

---@param style LiqUI_DesignStyle
---@param state LiqUI_DesignControlState
---@return ColorMixin
function Design:ResolveFill(style, state)
  local key = style.rest
  if not state.enabled then
    key = style.disabled or style.rest
  elseif state.selected and style.selected then
    key = style.selected
  elseif state.alt and style.alt then
    key = style.alt
  end
  return self.scale[key]
end

---@param style LiqUI_DesignStyle
---@param state LiqUI_DesignControlState
---@return number, number, number, number
function Design:ResolveWash(style, state)
  if not state.enabled then
    return 1, 1, 1, 0
  end
  if state.down and style.press then
    return 0, 0, 0, style.pressWash or 0
  end
  if state.over then
    return 1, 1, 1, style.hoverWash or 0
  end
  return 1, 1, 1, 0
end

---@param style LiqUI_DesignStyle
---@param state LiqUI_DesignControlState
---@param fill ColorMixin
---@return ColorMixin?
function Design:ResolveBorder(style, state, fill)
  if not style.borderPixels or style.borderPixels == 0 then
    return nil
  end
  if style.activeBorder then
    if state.enabled and (state.over or state.down or state.focused) then
      return self:ResolveActiveBorder(fill, style.borderTint)
    end
    return fill
  end
  local key = style.borderRest
  if state.focused and style.borderFocus then
    key = style.borderFocus
  end
  if key then
    return self.scale[key]
  end
  return fill
end

---@param fill ColorMixin
---@param tint number?
---@return ColorMixin
function Design:ResolveActiveBorder(fill, tint)
  local color = ensureColor(self.activeBorderColor)
  local red, green, blue = fill:GetRGB()
  local amount = (tint or 0) / 100
  color:SetRGB(mixChannel(red, 1, amount), mixChannel(green, 1, amount), mixChannel(blue, 1, amount))
  self.activeBorderColor = color
  return color
end

---@param parent Frame?
---@return number
local function parentPadding(parent)
  if not parent then
    return 0
  end
  return paddingByParent[parent] or 0
end

---@param region Region
---@return number
local function regionHeight(region)
  if region.GetStringHeight then
    return region:GetStringHeight()
  end
  return region:GetHeight()
end

---@param binding LiqUI_DesignSizeBinding
local function layoutSizedRegion(binding)
  local region = binding.region
  local parent = region:GetParent()
  local parentWidth = 0
  local parentHeight = 0
  local padding = parentPadding(parent)
  if parent then
    parentWidth = math.max(0, parent:GetWidth() - padding * 2)
    parentHeight = math.max(0, parent:GetHeight() - padding * 2)
  end
  local width = binding.width
  local height = binding.height
  if type(width) == "string" then
    local percent = tonumber(string.match(width, "^(%d+)%%$"))
    if percent then
      width = parentWidth * percent / 100
    else
      width = nil
    end
  end
  if type(height) == "string" then
    local percent = tonumber(string.match(height, "^(%d+)%%$"))
    if percent then
      height = parentHeight * percent / 100
    else
      height = nil
    end
  end
  if type(width) == "number" then
    SetPixelWidth(region, width)
  end
  if type(height) == "number" then
    SetPixelHeight(region, height)
  end
end

---@param stack LiqUI_DesignStack
local function layoutStack(stack)
  local parent = stack.parent
  stackLayoutActive[parent] = true
  local padding = parentPadding(parent)
  if stack.padding then
    padding = stack.padding
  end
  local y = -padding
  local regions = stack.regions
  for index = 1, #regions do
    local region = regions[index]
    SetPixelPoint(region, "TOPLEFT", parent, "TOPLEFT", padding, y)
    y = y - regionHeight(region) - stack.gap
  end
  SetPixelHeight(parent, math.max(1, -y + padding))
  stackLayoutActive[parent] = nil
  if stack.onLayout then
    stack.onLayout()
  end
end

---@param parent Frame?
function Design:RequestStackLayout(parent)
  if not parent then
    return
  end
  local stack = stacksByParent[parent]
  if not stack or stackLayoutQueued[parent] or stackLayoutActive[parent] then
    return
  end
  stackLayoutQueued[parent] = true
  C_Timer.After(0, function()
    stackLayoutQueued[parent] = nil
    local pending = stacksByParent[parent]
    if pending then
      layoutStack(pending)
    end
  end)
end

function Design:LayoutStacks()
  for index = 1, #stackList do
    self:RequestStackLayout(stackList[index].parent)
  end
end

---@param parent Frame
---@param padding number
function Design:SetPadding(parent, padding)
  paddingByParent[parent] = padding
end

---@param parent Frame
---@param region Region
---@param options LiqUI_DesignStackOptions?
function Design:Stack(parent, region, options)
  local stack = stacksByParent[parent]
  if not stack then
    ---@type LiqUI_DesignStack
    local created = {
      parent = parent,
      gap = (options and options.gap) or 0,
      regions = {},
      padding = options and options.padding,
      onLayout = options and options.onLayout,
    }
    stack = created
    stacksByParent[parent] = stack
    table.insert(stackList, stack)
    parent:HookScript("OnSizeChanged", function(frame)
      Design:RequestStackLayout(frame)
    end)
  end
  table.insert(stack.regions, region)
  self:RequestStackLayout(parent)
end

---@param region Region
---@param options LiqUI_DesignElementOptions
function Design:ApplySize(region, options)
  ---@type LiqUI_DesignSizeBinding
  local binding = {
    region = region,
    width = options.width,
    height = options.height,
  }
  layoutSizedRegion(binding)
  local parent = region:GetParent()
  if not parent then
    return
  end
  local bindings = sizeBindingsByParent[parent]
  if not bindings then
    bindings = {}
    sizeBindingsByParent[parent] = bindings
    parent:HookScript("OnSizeChanged", function(frame)
      local childBindings = sizeBindingsByParent[frame]
      if not childBindings then
        return
      end
      for index = 1, #childBindings do
        layoutSizedRegion(childBindings[index])
      end
      Design:RequestStackLayout(frame)
    end)
  end
  table.insert(bindings, binding)
  self:RequestStackLayout(parent)
end

local function rebuildTypeFonts()
  local file = DEFAULT_FONT_FILE
  if GameFontHighlight then
    local highlightFile = GameFontHighlight:GetFont()
    if highlightFile then
      file = highlightFile
    end
  end
  Design.fontFile = file
  Design.fontFlags = DEFAULT_FONT_FLAGS
  for index = 1, #TYPE_IDS do
    local typeId = TYPE_IDS[index]
    local style = Design.typography[typeId]
    local name = "LiqUIDesignType_" .. typeId
    local font = _G[name]
    if not font then
      font = CreateFont(name)
    end
    local file = style.file or Design.fontFile
    font:SetFont(file, style.size, style.flags or DEFAULT_FONT_FLAGS)
    font:SetSpacing(style.spacing or 0)
    font:SetShadowColor(0, 0, 0, 0)
    font:SetShadowOffset(0, 0)
    style.fontObject = font
  end
end

---@param fontString FontString
---@param typeId LiqUI_DesignTypeId
function Design:ApplyType(fontString, typeId)
  local style = self.typography[typeId]
  if not style.fontObject then
    rebuildTypeFonts()
  end
  fontString:SetFontObject(style.fontObject)
  local file = style.file or self.fontFile
  fontString:SetFont(file, style.size, style.flags or self.fontFlags)
  fontString:SetSpacing(style.spacing or 0)
  fontString:SetShadowColor(0, 0, 0, 0)
  fontString:SetShadowOffset(0, 0)
  local color = self.scale[style.color]
  fontString:SetTextColor(color:GetRGBA())
  if style.wrap then
    fontString:SetWordWrap(true)
    fontString:SetJustifyV("TOP")
    fontString:SetIndentedWordWrap(false)
  else
    fontString:SetWordWrap(false)
  end
  self:RequestStackLayout(fontString:GetParent())
end

rebuildTypeFonts()
