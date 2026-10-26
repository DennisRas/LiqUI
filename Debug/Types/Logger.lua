---@class LiqUI_LogEditBox : EditBox
---@field logText string

---@class LiqUI_LoggerDB
---@field autoScroll boolean
---@field autoShow boolean
---@field lines string[]

---@class LiqUI_NewLoggerOptions
---@field name string
---@field title string?
---@field storage LiqUI_LoggerDB
---@field maxLines number?

---@class LiqUI_LoggerHandle
---@field name string
---@field title string
---@field storage LiqUI_LoggerDB
---@field maxLines number?
---@field Log fun(self: LiqUI_LoggerHandle, prefixOrMessage: string, message: string?)
---@field Warn fun(self: LiqUI_LoggerHandle, message: string)
---@field Error fun(self: LiqUI_LoggerHandle, message: string)
---@field Clear fun(self: LiqUI_LoggerHandle)
---@field Toggle fun(self: LiqUI_LoggerHandle, state: boolean?)
---@field Show fun(self: LiqUI_LoggerHandle)
---@field Hide fun(self: LiqUI_LoggerHandle)

---@class LiqUI_Logger
---@field handles table<string, LiqUI_LoggerHandle>
---@field selectedAddonName string|nil
---@field window LiqUI_WindowInstance|nil
---@field refreshPending boolean
