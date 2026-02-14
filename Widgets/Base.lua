LiqUI.Widgets = LiqUI.Widgets or {}

local C = LiqUI.Config

local BaseControlDefaults = {
  height = C.control.height,
  backdrop = C.control.backdrop,
  backdropNoBorder = C.control.backdropNoBorder,
  borderColor = C.control.borderColor,
  borderColorHighlight = C.control.borderColorHighlight,
  borderColorFocus = C.control.borderColorFocus,
  backgroundColor = C.control.backgroundColor,
  backgroundColorHover = C.control.backgroundColorHover,
  backgroundColorPressed = C.control.backgroundColorPressed,
}

LiqUI.Widgets.BaseMixin = {}

function LiqUI.Widgets.BaseMixin:SetBorderState(state)
  local opts = self.options or {}
  local color = (state == "highlight" and opts.borderColorHighlight or BaseControlDefaults.borderColorHighlight)
      or (state == "focus" and opts.borderColorFocus or BaseControlDefaults.borderColorFocus)
      or opts.borderColor or BaseControlDefaults.borderColor
  self:SetBackdropBorderColor(color:GetRGBA())
end

local function applyBackdropColor(frame, color)
  if color and color.GetRGBA then
    frame:SetBackdropColor(color:GetRGBA())
  else
    local fallback = color or { 0.18, 0.18, 0.2, 1 }
    frame:SetBackdropColor(fallback[1], fallback[2], fallback[3], fallback[4] or 1)
  end
end

function LiqUI.Widgets.BaseMixin:SetBackgroundState(state)
  local opts = self.options or {}
  local color = (state == "highlight" and opts.backgroundColorHover or BaseControlDefaults.backgroundColorHover)
      or (state == "pressed" and opts.backgroundColorPressed or BaseControlDefaults.backgroundColorPressed)
      or opts.backgroundColor or BaseControlDefaults.backgroundColor
  applyBackdropColor(self, color)
end

function LiqUI.Widgets.BaseMixin:Init(defaults, opts)
  opts = LiqUI.Utils.PrepareOptions(LiqUI.Utils.PrepareOptions(BaseControlDefaults, defaults or {}), opts)
  self.options = opts
  self:SetSize(opts.width or 100, opts.height)
  self.backdropInfo = (opts.border == false) and opts.backdropNoBorder or opts.backdrop or BaseControlDefaults.backdrop
  self:ApplyBackdrop()
  self:SetBackgroundState("normal")
  self:SetBorderState("normal")
  self:SetScript("OnEnter", function()
    self:SetBorderState("highlight")
  end)
  self:SetScript("OnLeave", function()
    self:SetBorderState("normal")
  end)
  return opts
end
