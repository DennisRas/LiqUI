LiqUI.Mixins = LiqUI.Mixins or {}

---Adds highlight overlay to a frame. Use for hover/selection feedback.
---@class LiqUI_HighlightMixin
LiqUI.Mixins.Highlight = {}
local Highlight = LiqUI.Mixins.Highlight

function Highlight:SetVertexColor(r, g, b, a)
  if not self.Highlight then
    self.Highlight = self:CreateTexture("Highlight", "OVERLAY")
    self.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    self.Highlight:SetAllPoints()
    self.Highlight:Hide()
  end
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 0.05
  self.Highlight:SetVertexColor(r, g, b, a)
end

function Highlight:Show(r, g, b, a)
  if not self.Highlight then
    self:SetVertexColor(r, g, b, a)
  end
  self.Highlight:Show()
end

function Highlight:Hide()
  if not self.Highlight then
    return
  end
  self.Highlight:Hide()
end
