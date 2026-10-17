---@class LiqUI_ScrollAreaOptions
---@field name string?
---@field horizontal boolean?
---@field vertical boolean?
---@field wheelPanExtent number?

---@class LiqUI_ScrollBoxOptions
---@field barWidth number?

---@class LiqUI_ScrollBox : WowScrollBox
---@field scrollChild Frame
---@field ScrollBar MinimalScrollBar

---@class LiqUI_ScrollArea
---@field container Frame
---@field content Frame
---@field horizontal boolean
---@field vertical boolean
---@field verticalScrollBox WowScrollBox?
---@field verticalScrollBar MinimalScrollBar?
---@field horizontalScrollBox WowScrollBox?
---@field horizontalScrollBar (EventFrame & WowTrimHorizontalScrollBar)?
---@field wheelPanExtent number
---@field GetWheelScrollBox fun(self: LiqUI_ScrollArea): WowScrollBox?
---@field SetParent fun(self: LiqUI_ScrollArea, ...)
---@field SetPoint fun(self: LiqUI_ScrollArea, ...)
---@field SetAllPoints fun(self: LiqUI_ScrollArea, ...)
---@field ClearAllPoints fun(self: LiqUI_ScrollArea)
---@field HookScript fun(self: LiqUI_ScrollArea, ...)
---@field GetWidth fun(self: LiqUI_ScrollArea): number
---@field GetHeight fun(self: LiqUI_ScrollArea): number
---@field UpdateLayout fun(self: LiqUI_ScrollArea, contentWidth: number?, contentHeight: number?)
---@field ScrollToTop fun(self: LiqUI_ScrollArea)
---@field SetWheelPanExtent fun(self: LiqUI_ScrollArea, pixels: number)
---@field isUpdatingLayout boolean?

---@class LiqUI_ScrollingEditBoxHost
---@field textBox ScrollingEditBoxTemplate
---@field scrollBar MinimalScrollBar
