---@class LiqUI_InstanceWindow
---@field windows table<string, LiqUI_Window>

---@class LiqUI_InstanceTable
---@field frames LiqUI_TableFrame[]

---@class LiqUI_InstanceLogger
---@field loggers table<string, LiqUI_Logger>

---@class LiqUI_Instance
---@field name string
---@field db LiqUI_DB
---@field Window LiqUI_InstanceWindow
---@field Table LiqUI_InstanceTable
---@field Logger LiqUI_InstanceLogger

---@class LiqUI_NewOptions
---@field name string
---@field db LiqUI_DB

---@class LiqUI
---@field Utils LiqUI_Utils
---@field Mixins LiqUI_Mixins
---@field Constants LiqUI_Constants
---@field Window LiqUI_WindowManager
---@field Table LiqUI_TableManager
---@field Logger LiqUI_LoggerManager
---@field instances table<string, LiqUI_Instance>
---@field minor number

---@class LiqUI_Mixins
---@field Highlight LiqUI_HighlightMixin
