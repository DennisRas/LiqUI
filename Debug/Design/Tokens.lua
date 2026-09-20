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
    duration = 0.12,
  },
  window = {
    width = 880,
    height = 700,
    background = {normal = "shade90"},
    titlebar = {
      height = 32,
      background = {normal = "shade90"},
      button = {
        width = 32,
        height = 32,
        background = {normal = "shade90", hover = "shade75", pressed = "shade65", disabled = "shade90"},
        text = {normal = "white", disabled = "grey"},
      },
    },
    menu = {
      width = 180,
      padding = 8,
      background = {normal = "shade90"},
      row = {
        height = 32,
        gap = 0,
        padding = 12,
        round = true,
        background = {normal = "shade90", hover = "shade70", pressed = "shade50", selected = "shade60", disabled = "shade90"},
        text = {normal = "white", hover = "white", selected = "white", pressed = "white", disabled = "grey"},
        accent = {size = 4, color = "primary"},
      },
    },
    body = {padding = 16, background = {normal = "shade75"}},
    overlay = {alpha = 1, background = {normal = "shade90"}},
  },
  panel = {
    padding = 12,
    background = {normal = "shade80"},
    header = {
      height = 32,
      padding = 12,
      background = {normal = "shade90"},
      text = {normal = "white"},
    },
  },
  button = {
    primary = {
      height = 28,
      width = 120,
      round = true,
      background = {normal = "primary", hover = "tint10",pressed = "shade20", disabled = "shade80"},
      border = {size = 1, hover = "tint40", pressed = "tint20", disabled = "shade80"},
      text = {normal = "white", disabled = "grey"},
    },
    secondary = {
      height = 28,
      width = 120,
      round = true,
      background = {normal = "shade50", hover = "shade45", pressed = "shade50", disabled = "shade80"},
      border = {size = 1, hover = "shade10", pressed = "shade20", disabled = "shade80"},
      text = {normal = "white", disabled = "grey"},
    },
  },
  input = {
    height = 28,
    textInsets = 8,
    round = true,
    background = {normal = "shade90", hover = "shade80", disabled = "shade90"},
    border = {size = 1, color = "shade80", hover = "tint20", focus = "primary", disabled = "shade80"},
    text = {normal = "white", disabled = "grey"},
  },
  table = {
    background = {normal = "shade80"},
    cellPadding = 8,
    rowHeight = 28,
    highlightRows = false,
    highlightHeader = false,
    header = {
      background = {normal = "shade90", hover = "shade80", disabled = "shade90"},
    },
    row = {
      background = {normal = "shade85", hover = "shade65", alt = "shade80", disabled = "shade80"},
      text = {normal = "white", disabled = "grey"},
    },
  },
}
LiqUI.Design = Design
local TableMergeOptions = LiqUI.Utils.TableMergeOptions
local MixFrames = Mixin
local SetPixelWidth = PixelUtil.SetWidth
local SetPixelHeight = PixelUtil.SetHeight
local SetPixelPoint = PixelUtil.SetPoint
local WHITE8X8 = "Interface/BUTTONS/WHITE8X8"
local ROUND_TEXTURE = "Interface/AddOns/LiqUI/Debug/Design/Media/RoundedRect"
local ROUND_TEMPLATE = "LiqUIDesignRoundTemplate"
local ROUND_SLICE = 4
---@type LiqUI_DesignMixin[]
local painted = {}
---@type table<Texture|FontString, LiqUI_DesignColorAnim>
local colorAnims = {}
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
local SHADE_STEPS = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95}
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
  colors.grey = ensureColor(colors.grey)
  colors.grey:SetRGB(0.55, 0.55, 0.55)
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

---@param tokens LiqUI_DesignElement
---@return LiqUI_DesignBorder?
local function resolveBorder(tokens)
  if not tokens.background then
    return nil
  end
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

---@param state LiqUI_DesignElementState
---@param border LiqUI_DesignBorder
---@return boolean
local function roundBorderVisible(state, border)
  if not state.enabled then
    return border.color ~= nil
  end
  if state.down and border.pressed then
    return true
  end
  if state.selected and border.selected then
    return true
  end
  if state.over and border.hover then
    return true
  end
  if state.focused and border.focus then
    return true
  end
  return border.color ~= nil
end

---@param tokens LiqUI_DesignElement
---@return boolean
local function hasPointerState(tokens)
  local background = tokens.background
  if background and (background.hover or background.pressed) then
    return true
  end
  local border = tokens.border
  if border and (border.hover or border.pressed) then
    return true
  end
  local text = tokens.text
  if text and (text.hover or text.pressed) then
    return true
  end
  return false
end

---@param texture Texture
---@param snap boolean
local function applyTextureSnap(texture, snap)
  if texture.SetSnapToPixelGrid then
    texture:SetSnapToPixelGrid(snap)
  end
  if texture.SetTexelSnappingBias then
    texture:SetTexelSnappingBias(0)
  end
end

---@param parent Frame
---@param layer DrawLayer
---@param subLevel number
---@param round boolean
---@return Texture
local function createPaintTexture(parent, layer, subLevel, round)
  local texture
  if round then
    local ok, created = pcall(parent.CreateTexture, parent, nil, layer, ROUND_TEMPLATE, subLevel)
    if ok then
      texture = created
    end
  end
  if not texture then
    texture = parent:CreateTexture(nil, layer, nil, subLevel)
  end
  if round then
    local loaded = texture:SetTexture(ROUND_TEXTURE)
    if loaded then
      pcall(texture.SetTextureSliceMargins, texture, ROUND_SLICE, ROUND_SLICE, ROUND_SLICE, ROUND_SLICE)
      if Enum.UITextureSliceMode then
        pcall(texture.SetTextureSliceMode, texture, Enum.UITextureSliceMode.Stretched)
      end
    else
      texture:SetTexture(WHITE8X8)
    end
    applyTextureSnap(texture, true)
  else
    texture:SetTexture(WHITE8X8)
    applyTextureSnap(texture, false)
  end
  return texture
end

---@param region Region
---@param pixels number
---@return number
local function nearestInset(region, pixels)
  if pixels == 0 then
    return 0
  end
  return PixelUtil.GetNearestPixelSize(pixels, region:GetEffectiveScale(), 1)
end

---@param element LiqUI_DesignMixin
---@return Texture
local function makeSquareBorderEdge(element)
  local texture = element:CreateTexture(nil, "BACKGROUND", nil, -7)
  texture:SetTexture(WHITE8X8)
  applyTextureSnap(texture, false)
  return texture
end

---@param element LiqUI_DesignMixin
local function ensureSquareBorder(element)
  if element.SquareBorder then
    return
  end
  ---@type LiqUI_DesignSquareBorder
  local pieces = {
    Top = makeSquareBorderEdge(element),
    Bottom = makeSquareBorderEdge(element),
    Left = makeSquareBorderEdge(element),
    Right = makeSquareBorderEdge(element),
  }
  element.SquareBorder = pieces
end

---@param element LiqUI_DesignMixin
---@param size number
local function layoutSquareBorder(element, size)
  local pieces = element.SquareBorder
  if not pieces then
    return
  end
  SetPixelHeight(pieces.Top, size, 1)
  pieces.Top:ClearAllPoints()
  pieces.Top:SetPoint("TOPLEFT", element, "TOPLEFT", 0, 0)
  pieces.Top:SetPoint("TOPRIGHT", element, "TOPRIGHT", 0, 0)
  SetPixelHeight(pieces.Bottom, size, 1)
  pieces.Bottom:ClearAllPoints()
  pieces.Bottom:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 0, 0)
  pieces.Bottom:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 0, 0)
  SetPixelWidth(pieces.Left, size, 1)
  pieces.Left:ClearAllPoints()
  pieces.Left:SetPoint("TOPLEFT", element, "TOPLEFT", 0, 0)
  pieces.Left:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 0, 0)
  SetPixelWidth(pieces.Right, size, 1)
  pieces.Right:ClearAllPoints()
  pieces.Right:SetPoint("TOPRIGHT", element, "TOPRIGHT", 0, 0)
  pieces.Right:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 0, 0)
end

---@param element LiqUI_DesignMixin
---@param color ColorMixin
local function paintSquareBorderColor(element, color)
  local pieces = element.SquareBorder
  if not pieces then
    return
  end
  local red, green, blue, alpha = color:GetRGBA()
  pieces.Top:SetVertexColor(red, green, blue, alpha)
  pieces.Bottom:SetVertexColor(red, green, blue, alpha)
  pieces.Left:SetVertexColor(red, green, blue, alpha)
  pieces.Right:SetVertexColor(red, green, blue, alpha)
end

---@param element LiqUI_DesignMixin
---@param shown boolean
local function setSquareBorderShown(element, shown)
  local pieces = element.SquareBorder
  if not pieces then
    return
  end
  pieces.Top:SetShown(shown)
  pieces.Bottom:SetShown(shown)
  pieces.Left:SetShown(shown)
  pieces.Right:SetShown(shown)
end

---@param tokens LiqUI_DesignElement
---@return number
local function accentClipWidth(tokens)
  local accent = tokens.accent
  if not accent then
    return 0
  end
  return math.max(accent.size, ROUND_SLICE)
end

---@param element LiqUI_DesignMixin
---@param left number
---@param top number
---@param right number
---@param bottom number
local function layoutFill(element, left, top, right, bottom)
  local texture = element.Background
  texture:ClearAllPoints()
  if left == 0 and top == 0 and right == 0 and bottom == 0 then
    texture:SetAllPoints()
    return
  end
  texture:SetPoint("TOPLEFT", element, "TOPLEFT", left, -top)
  texture:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", -right, bottom)
end

---@param spec LiqUI_DesignBackground
---@param state LiqUI_DesignElementState
---@param defaultKey LiqUI_DesignColorKey
---@return LiqUI_DesignColorKey
local function fillKey(spec, state, defaultKey)
  if not state.enabled then
    return spec.disabled or spec.normal or defaultKey
  end
  if state.down and spec.pressed then
    return spec.pressed
  end
  if state.selected and spec.selected then
    return spec.selected
  end
  if state.over and spec.hover then
    return spec.hover
  end
  if state.alt and spec.alt then
    return spec.alt
  end
  return spec.normal or defaultKey
end

---@param region Texture|FontString
---@param color ColorMixin
---@param alpha number
---@param snap boolean
local function tweenVertexColor(region, color, alpha, snap)
  local red, green, blue = color:GetRGB()
  local handle = colorAnims[region]
  if snap or not Design.element.duration or Design.element.duration <= 0 then
    if handle then
      handle.group:Stop()
    end
    region:SetVertexColor(red, green, blue, alpha)
    return
  end
  local currentRed, currentGreen, currentBlue, currentAlpha = region:GetVertexColor()
  if handle and handle.group:IsPlaying() then
    handle.group:Stop()
    region:SetVertexColor(currentRed, currentGreen, currentBlue, currentAlpha)
  end
  if math.abs(currentRed - red) < 0.002 and math.abs(currentGreen - green) < 0.002 and math.abs(currentBlue - blue) < 0.002 and math.abs((currentAlpha or 1) - alpha) < 0.002 then
    region:SetVertexColor(red, green, blue, alpha)
    return
  end
  if not handle then
    local group = region:CreateAnimationGroup()
    ---@type LiqUI_DesignVertexColorAnim
    local anim = group:CreateAnimation("VertexColor")
    anim:SetSmoothing("IN_OUT")
    ---@type LiqUI_DesignColorAnim
    local created = {
      group = group,
      anim = anim,
      from = CreateColor(currentRed, currentGreen, currentBlue, currentAlpha or 1),
      to = CreateColor(red, green, blue, alpha),
    }
    handle = created
    colorAnims[region] = handle
    group:SetScript("OnFinished", function()
      local finished = colorAnims[region]
      if not finished then
        return
      end
      local finishedRed, finishedGreen, finishedBlue, finishedAlpha = finished.to:GetRGBA()
      region:SetVertexColor(finishedRed, finishedGreen, finishedBlue, finishedAlpha)
    end)
  end
  handle.anim:SetDuration(Design.element.duration)
  handle.from:SetRGBA(currentRed, currentGreen, currentBlue, currentAlpha or 1)
  handle.to:SetRGBA(red, green, blue, alpha)
  handle.anim:SetStartColor(handle.from)
  handle.anim:SetEndColor(handle.to)
  handle.group:Stop()
  handle.group:Play()
end

---@param element LiqUI_DesignMixin
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
---@return ColorMixin?
function Design:BackgroundColor(tokens, state)
  local spec = tokens.background
  if not spec then
    return nil
  end
  local key = fillKey(spec, state, spec.normal)
  return self.colors[key]
end

---@param tokens LiqUI_DesignElement
---@param state LiqUI_DesignElementState
---@return ColorMixin
function Design:TextColor(tokens, state)
  local spec = tokens.text
  if not spec then
    if not state.enabled then
      return self.colors.grey
    end
    return self.colors.white
  end
  local key = spec.normal
  if not state.enabled then
    key = spec.disabled or spec.normal
  elseif state.down and spec.pressed then
    key = spec.pressed
  elseif state.selected and spec.selected then
    key = spec.selected
  elseif state.over and spec.hover then
    key = spec.hover
  end
  return self.colors[key]
end

---@param tokens LiqUI_DesignElement
---@param state LiqUI_DesignElementState
---@param fill ColorMixin?
---@return ColorMixin?
function Design:BorderColor(tokens, state, fill)
  local border = resolveBorder(tokens)
  if not border then
    return nil
  end
  local color = fill
  if border.color then
    color = self.colors[border.color]
  end
  if not state.enabled then
    if border.disabled then
      return self.colors[border.disabled]
    end
    return color
  end
  if state.down and border.pressed then
    return self.colors[border.pressed]
  end
  if state.selected and border.selected then
    return self.colors[border.selected]
  end
  if state.over and border.hover then
    return self.colors[border.hover]
  end
  if state.focused and border.focus then
    return self.colors[border.focus]
  end
  return color
end

---@param element LiqUI_DesignMixin
---@param fill ColorMixin
---@param state LiqUI_DesignElementState
function Design:PaintSquareBorder(element, fill, state)
  local border = resolveBorder(element.tokens)
  if not border or element.tokens.round then
    setSquareBorderShown(element, false)
    return
  end
  ensureSquareBorder(element)
  setSquareBorderShown(element, true)
  layoutSquareBorder(element, border.size)
  if element.Background then
    local size = nearestInset(element, border.size)
    layoutFill(element, size, size, size, size)
  end
  local color = self:BorderColor(element.tokens, state, fill)
  if color then
    paintSquareBorderColor(element, color)
  end
end

---@param element LiqUI_DesignMixin
function Design:Paint(element)
  local tokens = element.tokens
  local state = self:ElementState(element)
  local fill = self:BackgroundColor(tokens, state)
  local snap = self.snapPaint and true or false
  local alpha = tokens.alpha or 1
  local left, top, right, bottom = 0, 0, 0, 0
  local border = resolveBorder(tokens)
  local showRoundBorder = tokens.round and element.Border and border and roundBorderVisible(state, border)
  if showRoundBorder and border then
    local size = nearestInset(element, border.size)
    left, top, right, bottom = size, size, size, size
  end
  if tokens.round and element.Background then
    layoutFill(element, left, top, right, bottom)
  end
  if element.Background and fill then
    tweenVertexColor(element.Background, fill, alpha, snap)
  end
  if element.Border then
    local borderColor = self:BorderColor(tokens, state, fill)
    if borderColor then
      local borderSnap = snap or not showRoundBorder
      tweenVertexColor(element.Border, borderColor, alpha, borderSnap)
    end
  else
    self:PaintSquareBorder(element, fill, state)
  end
  if element.AccentClip and tokens.accent then
    SetPixelWidth(element.AccentClip, accentClipWidth(tokens), 1)
  end
  if element.Accent and tokens.accent then
    local accentColor = self.colors[tokens.accent.color]
    local accentAlpha = 0
    if state.enabled and state.selected then
      accentAlpha = 1
    end
    tweenVertexColor(element.Accent, accentColor, accentAlpha, snap)
  end
  local textColor = self:TextColor(tokens, state)
  local fontString = element.GetFontString and element:GetFontString()
  if fontString then
    tweenVertexColor(fontString, textColor, 1, snap)
  end
  local cells = element.cells
  if cells then
    for index = 1, #cells do
      tweenVertexColor(cells[index], textColor, 1, snap)
    end
  end
  if tokens.textInsets then
    element:SetTextColor(textColor:GetRGBA())
  end
  local instructions = element.Instructions
  if instructions then
    tweenVertexColor(instructions, self.colors.grey, 1, snap)
    instructions:SetShown(element:GetText() == "")
  end
end

function Design:PaintAll()
  self.snapPaint = true
  for index = 1, #painted do
    painted[index]:Apply()
  end
  self.snapPaint = nil
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
  local round = tokens.round and true or false
  local border = resolveBorder(tokens)
  if tokens.background then
    local background = createPaintTexture(self, layer, 0, round)
    self.Background = background
    if round then
      if border then
        local borderTexture = createPaintTexture(self, layer, -1, true)
        borderTexture:SetAllPoints()
        self.Border = borderTexture
      end
      background:SetAllPoints()
    else
      if border then
        ensureSquareBorder(self)
        layoutSquareBorder(self, border.size)
        local size = nearestInset(self, border.size)
        layoutFill(self, size, size, size, size)
      else
        background:SetAllPoints()
      end
    end
  end
  if tokens.accent then
    local accent
    if round then
      local clip = CreateFrame("Frame", nil, self)
      clip:EnableMouse(false)
      clip:SetClipsChildren(true)
      clip:SetFrameLevel(self:GetFrameLevel() + 1)
      SetPixelPoint(clip, "TOPLEFT", self, "TOPLEFT", 0, 0)
      SetPixelPoint(clip, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
      SetPixelWidth(clip, accentClipWidth(tokens), 1)
      accent = createPaintTexture(clip, layer, 0, true)
      accent:SetAllPoints(self)
      self.AccentClip = clip
    else
      accent = self:CreateTexture(nil, "ARTWORK")
      accent:SetDrawLayer("ARTWORK", 2)
      accent:SetTexture(WHITE8X8)
      SetPixelPoint(accent, "TOPLEFT", self, "TOPLEFT", 0, 0)
      SetPixelPoint(accent, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
      SetPixelWidth(accent, tokens.accent.size)
    end
    accent:SetVertexColor(1, 1, 1, 0)
    self.Accent = accent
  end
  if hasPointerState(tokens) then
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
  local snap = Design.snapPaint
  Design.snapPaint = true
  Design:Paint(self)
  Design.snapPaint = snap
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
