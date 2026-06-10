---@class LiqUI_TitlebarButton
---@field name string
---@field icon string
---@field tooltipTitle string
---@field tooltipDescription string
---@field onClick function?
---@field setupMenu function?
---@field size number?
---@field iconSize number?
---@field enabled boolean?

---@class LiqUI_Window : Frame
---@field config LiqUI_WindowOptions
---@field db table|nil
---@field titlebar Frame?
---@field body LiqUI_WindowBody?
---@field sidebar Frame?
---@field border Frame?
---@field progressOverlay LiqUI_WindowProgressOverlay?
---@field titlebarButtons Frame[]
---@field width number?
---@field height number?

---@class LiqUI_WindowBody : Frame
---@field placeholderText FontString?

---@class LiqUI_WindowManager
---@field windows table<string, LiqUI_Window>

---@class LiqUI_WindowOptions
---@field parent Frame?
---@field name string?
---@field title string?
---@field icon string?
---@field point table?
---@field width number?
---@field height number?
---@field sidebar number?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor ColorTable?
---@field titlebarButtons LiqUI_TitlebarButton[]?

---@class LiqUI_WindowProgressBar : StatusBar
---@field background Texture

---@class LiqUI_WindowProgressOverlay : Frame
---@field content Frame
---@field text FontString
---@field bar LiqUI_WindowProgressBar
