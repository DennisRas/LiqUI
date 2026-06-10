---@class LiqUI_LoggerState
---@field enabled boolean
---@field autoScroll boolean
---@field autoShow boolean
---@field lines string[]

---@class LiqUI_LoggerOptions
---@field name string?
---@field title string?
---@field width number?
---@field height number?
---@field bodyPadding number?
---@field linesMax number?
---@field clearIcon string?
---@field clearIconSize number?
---@field fontObject string?
---@field onWindowShow function?

---@class LiqUI_Logger
---@field db LiqUI_LoggerState
---@field config LiqUI_LoggerOptions
---@field window LiqUI_Window|nil
---@field refreshPending boolean

---@class LiqUI_LoggerManager
