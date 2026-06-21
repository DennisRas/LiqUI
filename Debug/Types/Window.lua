---@class LiqUI_WindowTitlebarButton
---@field name string
---@field icon string
---@field tooltipTitle string
---@field tooltipDescription string
---@field onClick function?
---@field onMenu fun(window: LiqUI_WindowInstance, rootMenu: table)?
---@field size number?
---@field iconSize number?
---@field enabled boolean?

---@alias LiqUI_WindowPointPersisted [string, string, number, number]

---@class LiqUI_Window
---@field embed LiqUI_Instance
---@field instances table<string, LiqUI_WindowInstance>

---@class LiqUI_WindowInstance : Frame
---@field options LiqUI_WindowOptions
---@field db LiqUI_WindowDB|nil
---@field titlebar Frame?
---@field body LiqUI_WindowBody?
---@field overlay LiqUI_WindowOverlay?
---@field overlayLastShowOptions LiqUI_WindowOverlayOptions|nil
---@field border Frame?
---@field titlebarButtons Frame[]
---@field width number?
---@field height number?

---@class LiqUI_WindowBody : Frame
---@field scrollArea LiqUI_ScrollArea?

---@class LiqUI_WindowDB
---@field point LiqUI_WindowPointPersisted?
---@field scale number?
---@field windowColor ColorTable?
---@field border boolean?

---@class LiqUI_WindowOverlayOptions
---@field fontObject string?
---@field textColor ColorTable?
---@field backgroundColor ColorTable?

---@class LiqUI_WindowOptions
---@field parent Frame?
---@field name string?
---@field title string?
---@field icon string?
---@field point LiqUI_WindowPointPersisted?
---@field width number?
---@field height number?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor ColorTable?
---@field overlayFontObject string?
---@field overlayTextColor ColorTable?
---@field overlayBackgroundColor ColorTable?
---@field titlebarButtons LiqUI_WindowTitlebarButton[]?
---@field onSettingsMenu fun(window: LiqUI_WindowInstance, rootMenu: table)?
---@field onClose fun(window: LiqUI_WindowInstance)?
---@field onShow fun(window: LiqUI_WindowInstance)?

---@class LiqUI_WindowProgressBar : StatusBar
---@field background Texture

---@class LiqUI_WindowOverlay : Frame
---@field text FontString
---@field bar LiqUI_WindowProgressBar
