---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Design
local Design = LiqUI.Design or {
  colors = {},
  listeners = {},
  typography = {
    h1 = {size = 24, spacing = 4, color = "white"},
    h2 = {size = 20, spacing = 3, color = "white"},
    h3 = {size = 18, spacing = 2, color = "white"},
    title = {size = 13, spacing = 0, color = "white"},
    p = {size = 12, spacing = 4, wrap = true, color = "white"},
    label = {size = 12, spacing = 0, color = "white"},
  },
  layout = {
    gap = 8,
    sectionGap = 16,
    scrollBar = 12,
    swatchSize = 40,
    swatchGap = 8,
  },
  element = {
    border = {size = 1},
    highlight = {color = "white", alpha = 0.1},
    pushed = {color = "black", alpha = 0.25},
  },
  window = {
    width = 880,
    height = 700,
    background = {normal = "shade80"},
    border = {size = 1, color = "shade50"},
    titlebar = {
      height = 32,
      background = {normal = "shade90"},
      button = {
        width = 32,
        height = 32,
        background = {normal = "shade90", disabled = "shade90"},
        highlight = true,
        pushed = true,
      },
    },
    menu = {
      width = 180,
      padding = 14,
      background = {normal = "shade80"},
      row = {
        height = 30,
        gap = 0,
        background = {normal = "shade80", selected = "primary", disabled = "shade80"},
        highlight = true,
        pushed = true,
      },
    },
    body = {padding = 16, background = {normal = "shade70"}},
    overlay = {alpha = 0.85, background = {normal = "shade90"}},
  },
  button = {
    primary = {
      height = 28,
      width = 100,
      background = {normal = "primary", disabled = "shade80"},
      border = {size = 2, highlightTint = 35},
      highlight = true,
      pushed = true,
    },
    secondary = {
      height = 28,
      width = 100,
      background = {normal = "shade50", disabled = "shade80"},
      border = {size = 2, highlightTint = 35},
      highlight = true,
      pushed = true,
    },
  },
  input = {
    height = 28,
    textInsets = 8,
    background = {normal = "shade80", disabled = "shade90"},
    border = {size = 1, color = "shade50", focus = "primary"},
    highlight = true,
  },
  table = {
    background = {normal = "shade80"},
    border = {size = 1, color = "shade50"},
    cellPadding = 8,
    rowHeight = 28,
    highlightRows = false,
    highlightHeader = false,
    header = {
      background = {normal = "shade90", disabled = "shade90"},
      highlight = true,
    },
    row = {
      background = {normal = "shade80", alt = "shade70", selected = "primary", disabled = "shade80"},
      highlight = true,
      pushed = true,
    },
  },
}
LiqUI.Design = Design
local TableMergeOptions = LiqUI.Utils.TableMergeOptions
local SetPixelBackdrop = LiqUI.Utils.SetPixelBackdrop
local MixFrames = Mixin
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
local SetPixelPoint = PixelUtil.SetPoint
local WHITE8X8 = "Interface/BUTTONS/WHITE8X8"
---@type LiqUI_DesignSandboxElement[]
local painted = {}
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

---@param colors LiqUI_DesignColors
---@param r number
---@param g number
---@param b number
---@param steps number[]
---@param prefix string
---@param towardR number
---@param towardG number
---@param towardB number
local function rebuildSteps(colors, r, g, b, steps, prefix, towardR, towardG, towardB)
  for index = 1, #steps do
    local step = steps[index]
    local amount = step / 100
    local key = prefix .. step
    local color = ensureColor(colors[key])
    color:SetRGB(mixChannel(r, towardR, amount), mixChannel(g, towardG, amount), mixChannel(b, towardB, amount))
    colors[key] = color
  end
end

---@param r number
---@param g number
---@param b number
local function rebuild(r, g, b)
  local colors = Design.colors
  colors.primary = ensureColor(colors.primary)
  colors.primary:SetRGB(r, g, b)
  colors.white = ensureColor(colors.white)
  colors.white:SetRGB(1, 1, 1)
  colors.black = ensureColor(colors.black)
  colors.black:SetRGB(0, 0, 0)
  rebuildSteps(colors, r, g, b, TINT_STEPS, "tint", 1, 1, 1)
  rebuildSteps(colors, r, g, b, SHADE_STEPS, "shade", 0, 0, 0)
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
  local primary = self.colors.primary
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

---@param spec LiqUI_DesignOverlaySpec?
---@param recipe LiqUI_DesignOverlay
---@return LiqUI_DesignOverlay?
local function resolveOverlay(spec, recipe)
  if spec == nil or spec == false then
    return nil
  end
  if spec == true then
    return recipe
  end
  local merged = {}
  TableMergeOptions(merged, recipe)
  TableMergeOptions(merged, spec)
  return merged
end

---@param tokens LiqUI_DesignElement
---@return LiqUI_DesignBorder?
local function resolveBorder(tokens)
  local border = tokens.border
  if not border then
    return nil
  end
  local merged = {}
  TableMergeOptions(merged, Design.element.border)
  TableMergeOptions(merged, border)
  if not merged.size or merged.size == 0 then
    return nil
  end
  return merged
end

---@param region Region
---@param texture Texture
---@param inset number
local function insetBackground(region, texture, inset)
  texture:ClearAllPoints()
  SetPixelPoint(texture, "TOPLEFT", region, "TOPLEFT", inset, -inset, 1, 1)
  SetPixelPoint(texture, "BOTTOMRIGHT", region, "BOTTOMRIGHT", -inset, inset, 1, 1)
end

---@param element LiqUI_DesignSandboxElement
---@return LiqUI_DesignElementState
function Design:ElementState(element)
  local enabled = true
  if element.IsEnabled then
    enabled = element:IsEnabled() and true or false
  end
  local over = element.previewOver
  if not over and element.IsOver then
    over = element:IsOver() and true or false
  end
  local down = element.previewDown
  if not down and element.IsDown then
    down = element:IsDown() and true or false
  end
  if element.allowHighlight == false then
    over = false
    down = false
  end
  ---@type LiqUI_DesignElementState
  local state = {
    enabled = enabled,
    over = over and true or false,
    down = down and true or false,
    selected = element.selected,
    focused = element.focused,
    alt = element.alt,
  }
  return state
end

---@param tokens LiqUI_DesignElement
---@param state LiqUI_DesignElementState
---@return ColorMixin
function Design:BackgroundColor(tokens, state)
  local background = tokens.background
  local key = background.normal
  if not state.enabled then
    key = background.disabled or background.normal
  elseif state.selected and background.selected then
    key = background.selected
  elseif state.alt and background.alt then
    key = background.alt
  end
  return self.colors[key]
end

---@param fill ColorMixin
---@param tint number
---@return ColorMixin
local function mixTowardWhite(fill, tint)
  local color = ensureColor(Design.borderMixColor)
  local red, green, blue = fill:GetRGB()
  local amount = tint / 100
  color:SetRGB(mixChannel(red, 1, amount), mixChannel(green, 1, amount), mixChannel(blue, 1, amount))
  Design.borderMixColor = color
  return color
end

---@param element LiqUI_DesignSandboxElement
---@param fill ColorMixin
---@param state LiqUI_DesignElementState
function Design:PaintBorder(element, fill, state)
  local border = resolveBorder(element.tokens)
  if not border then
    return
  end
  SetPixelBackdrop(element, border.size, false)
  insetBackground(element, element.Background, border.size)
  insetBackground(element, element.Highlight, border.size)
  local color = fill
  if state.focused and border.focus then
    color = self.colors[border.focus]
  elseif border.color then
    color = self.colors[border.color]
  end
  if state.enabled and (state.over or state.down) and border.highlightTint then
    color = mixTowardWhite(color, border.highlightTint)
  end
  element:SetBackdropBorderColor(color:GetRGBA())
end

---@param element LiqUI_DesignSandboxElement
---@param fill ColorMixin
---@param tokens LiqUI_DesignElement
function Design:PaintBackground(element, fill, tokens)
  local alpha = tokens.alpha or 1
  local red, green, blue = fill:GetRGB()
  element.Background:SetVertexColor(red, green, blue, alpha)
end

---@param element LiqUI_DesignSandboxElement
---@param tokens LiqUI_DesignElement
---@param state LiqUI_DesignElementState
function Design:PaintHighlight(element, tokens, state)
  local overlay
  if state.enabled and state.down then
    overlay = resolveOverlay(tokens.pushed, self.element.pushed)
  end
  if not overlay and state.enabled and state.over then
    overlay = resolveOverlay(tokens.highlight, self.element.highlight)
  end
  if not overlay then
    element.Highlight:SetVertexColor(1, 1, 1, 0)
    return
  end
  local color = self.colors[overlay.color]
  local red, green, blue = color:GetRGB()
  element.Highlight:SetVertexColor(red, green, blue, overlay.alpha)
end

---@param element LiqUI_DesignSandboxElement
function Design:Paint(element)
  local tokens = element.tokens
  local state = self:ElementState(element)
  local fill = self:BackgroundColor(tokens, state)
  self:PaintBackground(element, fill, tokens)
  self:PaintHighlight(element, tokens, state)
  self:PaintBorder(element, fill, state)
  local textColor = self.colors.white
  if not state.enabled then
    textColor = self.colors.tint50
  end
  local fontString = element.GetFontString and element:GetFontString()
  if fontString then
    fontString:SetTextColor(textColor:GetRGBA())
  end
  if tokens.textInsets then
    element:SetTextColor(textColor:GetRGBA())
  end
  local instructions = element.Instructions
  if instructions then
    instructions:SetTextColor(self.colors.tint50:GetRGBA())
    instructions:SetShown(element:GetText() == "")
  end
end

function Design:PaintAll()
  for index = 1, #painted do
    painted[index]:Apply()
  end
end

---@class LiqUI_DesignMixin
local ElementMixin = {}
Design.Mixin = ElementMixin

---@param tokens LiqUI_DesignElement
function ElementMixin:Setup(tokens)
  self.tokens = tokens
  local layer = "ARTWORK"
  if tokens.textInsets then
    layer = "BACKGROUND"
  end
  local background = self:CreateTexture(nil, layer)
  background:SetDrawLayer(layer, 0)
  background:SetTexture(WHITE8X8)
  self.Background = background
  local highlight = self:CreateTexture(nil, "ARTWORK")
  highlight:SetDrawLayer("ARTWORK", 1)
  highlight:SetTexture(WHITE8X8)
  self.Highlight = highlight
  local border = resolveBorder(tokens)
  if border then
    SetPixelBackdrop(self, border.size, false)
    insetBackground(self, background, border.size)
    insetBackground(self, highlight, border.size)
  else
    background:SetAllPoints()
    highlight:SetAllPoints()
  end
  if tokens.highlight or tokens.pushed then
    MixFrames(self, ButtonStateBehaviorMixin)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
    self:SetScript("OnMouseDown", self.OnMouseDown)
    self:SetScript("OnMouseUp", self.OnMouseUp)
    if not tokens.textInsets then
      self:SetScript("OnEnable", self.OnEnable)
      self:SetScript("OnDisable", self.OnDisable)
    end
    self.OnButtonStateChanged = self.Apply
  end
  if tokens.padding then
    Design:SetPadding(self, tokens.padding)
  end
  table.insert(painted, self)
  Design:Paint(self)
end

function ElementMixin:Apply()
  Design:Paint(self)
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
---@param options LiqUI_DesignSizeOptions
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
  local color = self.colors[style.color]
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
