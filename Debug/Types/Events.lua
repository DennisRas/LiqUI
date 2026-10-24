---@alias LiqUI_EventCallback fun(frame: Frame, event: string, ...)

---@class LiqUI_EventPackedVarargs
---@field n number

---@class LiqUI_EventHandlerEntry
---@field fn LiqUI_EventCallback
---@field runsImmediately boolean

---@class LiqUI_EventBucketPending
---@field timer FunctionContainer?
---@field packedVarargs LiqUI_EventPackedVarargs

---@class LiqUI_EventRuntime
---@field pendingByEventName table<string, LiqUI_EventBucketPending>

---@class LiqUI_Events
---@field handlers table<string, LiqUI_EventHandlerEntry[]>
---@field frame Frame
---@field runtime LiqUI_EventRuntime
