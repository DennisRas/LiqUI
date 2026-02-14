---@class LiqUI
---@field Utils table
---@field Mixins LiqUI_Mixins
---@field Window LiqUI_WindowManager
---@field version string

---@class LiqUI_Mixins
---@field Highlight LiqUI_HighlightMixin

---@class LiqUI_HighlightMixin
---@field SetVertexColor fun(self: table, r?: number, g?: number, b?: number, a?: number)
---@field Show fun(self: table, r?: number, g?: number, b?: number, a?: number)
---@field Hide fun(self: table)

---@class LiqUI_WindowOptions
---@field parent Frame?
---@field name string?
---@field title string?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor table?
---@field point any?
---@field icon string? Optional texture path for titlebar icon

---@class LiqUI_WindowManager
---@field New fun(self: LiqUI_WindowManager, options: LiqUI_WindowOptions): LiqUI_WindowFrame
---@field GetWindow fun(self: LiqUI_WindowManager, name: string): LiqUI_WindowFrame?
---@field SetWindowScale fun(self: LiqUI_WindowManager, scale: number)
---@field SetWindowBackgroundColor fun(self: LiqUI_WindowManager, color: table)
---@field GetMaxWindowWidth fun(self: LiqUI_WindowManager): number
---@field ToggleWindow fun(self: LiqUI_WindowManager, name: string?)

---@class LiqUI_WindowFrame : table|BackdropTemplate|Frame
---@field config LiqUI_WindowOptions
---@field body Frame
---@field titlebar Frame?
---@field Toggle fun(self: LiqUI_WindowFrame, state: boolean?)
---@field SetTitle fun(self: LiqUI_WindowFrame, title: string)
---@field SetBodySize fun(self: LiqUI_WindowFrame, width: number, height: number)
