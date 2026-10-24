---@alias LiqUI_MenuGenerator fun(ownerRegion: Region, rootMenu: RootMenuDescriptionProxy, ...)

---@class LiqUI_WindowTitlebarButton
---@field name string
---@field icon string
---@field tooltipTitle string
---@field tooltipDescription string
---@field onClick function?
---@field onMenu fun(window: LiqUI_WindowInstance, rootMenu: RootMenuDescriptionProxy)?
---@field size number?
---@field iconSize number?
---@field enabled boolean?

---@alias LiqUI_WindowPointPersisted [string, string, number, number]

---@class LiqUI_WindowDefaultPosition
---@field topLeftX number
---@field topLeftY number

---@class LiqUI_WindowTitlebarDropdownButton : DropdownButton
---@field Icon Texture
---@field menuGenerator LiqUI_MenuGenerator?

---@class LiqUI_WindowTitlebar : Frame
---@field icon Texture
---@field title FontString
---@field CloseButton Button
---@field SettingsButton LiqUI_WindowTitlebarDropdownButton

---@class LiqUI_WindowInstance : Frame
---@field options LiqUI_WindowOptions
---@field db LiqUI_WindowDB|nil
---@field titlebar LiqUI_WindowTitlebar
---@field body LiqUI_WindowBody
---@field overlay LiqUI_WindowOverlay
---@field overlayLastShowOptions LiqUI_WindowOverlayOptions|nil
---@field border (Frame & BackdropTemplate)?
---@field titlebarButtons Frame[]
---@field width number?
---@field height number?
---@field Close fun(self: LiqUI_WindowInstance)
---@field Toggle fun(self: LiqUI_WindowInstance, state: boolean?)
---@field SetTitle fun(self: LiqUI_WindowInstance, title: string)
---@field SetBodySize fun(self: LiqUI_WindowInstance, width: number, height: number)
---@field ShowOverlay fun(self: LiqUI_WindowInstance, text: string|nil, progress: number|nil, showOptions: LiqUI_WindowOverlayOptions|nil)
---@field HideOverlay fun(self: LiqUI_WindowInstance)
---@field IsOverlayShown fun(self: LiqUI_WindowInstance): boolean
---@field AddTitlebarButton fun(self: LiqUI_WindowInstance, buttonConfig: LiqUI_WindowTitlebarButton): Frame
---@field RemoveTitlebarButton fun(self: LiqUI_WindowInstance, buttonName: string)
---@field GetTitlebarButton fun(self: LiqUI_WindowInstance, buttonName: string): Frame?
---@field GetWindowScale fun(self: LiqUI_WindowInstance): number
---@field SetWindowScale fun(self: LiqUI_WindowInstance, scalePercent: number)
---@field GetWindowColor fun(self: LiqUI_WindowInstance): ColorTable?
---@field SetWindowColor fun(self: LiqUI_WindowInstance, color: ColorTable)
---@field GetBorderShown fun(self: LiqUI_WindowInstance): boolean
---@field SetBorderShown fun(self: LiqUI_WindowInstance, shown: boolean)
---@field ApplySettings fun(self: LiqUI_WindowInstance)
---@field SaveSettings fun(self: LiqUI_WindowInstance)
---@field Render fun(self: LiqUI_WindowInstance)
---@field AppendWindowOptionsMenu fun(self: LiqUI_WindowInstance, rootMenu: RootMenuDescriptionProxy, onRefresh: fun()|nil)

---@class LiqUI_WindowBody : Frame
---@field scrollArea LiqUI_ScrollArea?
---@field textBox ScrollingEditBoxTemplate?
---@field scrollBar MinimalScrollBar?

---@class LiqUI_WindowDB
---@field point LiqUI_WindowPointPersisted?
---@field scale number?
---@field windowColor ColorTable?
---@field border boolean?

---@class LiqUI_WindowOverlayOptions
---@field fontObject string?
---@field textColor ColorTable?
---@field backgroundColor ColorTable?

---@class LiqUI_WindowOptions : LiqUI_NewElementOptions
---@field parent Frame?
---@field storage LiqUI_WindowDB?
---@field title string?
---@field icon string?
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
---@field onSettingsMenu fun(window: LiqUI_WindowInstance, rootMenu: RootMenuDescriptionProxy)?
---@field onClose fun(window: LiqUI_WindowInstance)?
---@field onShow fun(window: LiqUI_WindowInstance)?

---@class LiqUI_WindowProgressBar : StatusBar
---@field background Texture

---@class LiqUI_WindowOverlay : Frame
---@field text FontString
---@field bar LiqUI_WindowProgressBar
