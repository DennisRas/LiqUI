---@alias ColorTable { r: number, g: number, b: number, a: number }

---@class LiqUI_Constants

---@class LiqUI_DB
---@field windows table<string, LiqUI_WindowDB>
---@field tables table<string, LiqUI_TableDB>

---@class LiqUI_RegisterAddonOptions
---@field name string
---@field title string?

---@class LiqUI_RegisteredAddon
---@field name string
---@field title string

---@class LiqUI
---@field Utils LiqUI_Utils
---@field Mixins LiqUI_Mixins
---@field Constants LiqUI_Constants
---@field Logger LiqUI_Logger
---@field elements table<string, fun(options: table): any>
---@field created table<string, table<string, any>>
---@field registeredAddons table<string, LiqUI_RegisteredAddon>
---@field minor number

---@class LiqUI_Mixins
---@field Highlight LiqUI_HighlightMixin
