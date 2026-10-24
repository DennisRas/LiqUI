---@alias ColorTable { r: number, g: number, b: number, a: number }

---@class LiqUI_LabelAnchor
---@field point FramePoint?
---@field relativeTo Region?
---@field relativePoint FramePoint?
---@field x number?
---@field y number?

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

---@class LiqUI_NewElementOptions
---@field name string

---@class LiqUI
---@field Utils LiqUI_Utils
---@field Mixins LiqUI_Mixins
---@field Constants LiqUI_Constants
---@field Logger LiqUI_Logger
---@field Events LiqUI_Events
---@field Data LiqUI_Data
---@field EJScan LiqUI_EJScan
---@field elements table<string, fun(options: LiqUI_NewElementOptions): table>
---@field created table<string, table<string, table>>
---@field registeredAddons table<string, LiqUI_RegisteredAddon>
---@field minor number

---@class LiqUI_HighlightMixin : Frame
---@field Highlight Texture?

---@class LiqUI_Mixins
---@field Highlight LiqUI_HighlightMixin
