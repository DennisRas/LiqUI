---@class LiqUI_DesignDB
---@field primary ColorTable
---@field point LiqUI_WindowPointPersisted?

---@class LiqUI_DesignScale
---@field primary ColorMixin
---@field tint10 ColorMixin
---@field tint20 ColorMixin
---@field tint30 ColorMixin
---@field tint40 ColorMixin
---@field tint50 ColorMixin
---@field tint60 ColorMixin
---@field tint70 ColorMixin
---@field tint80 ColorMixin
---@field tint90 ColorMixin
---@field shade10 ColorMixin
---@field shade20 ColorMixin
---@field shade30 ColorMixin
---@field shade40 ColorMixin
---@field shade50 ColorMixin
---@field shade60 ColorMixin
---@field shade70 ColorMixin
---@field shade80 ColorMixin
---@field shade90 ColorMixin

---@alias LiqUI_DesignScaleKey "primary"|"tint10"|"tint20"|"tint30"|"tint40"|"tint50"|"tint60"|"tint70"|"tint80"|"tint90"|"shade10"|"shade20"|"shade30"|"shade40"|"shade50"|"shade60"|"shade70"|"shade80"|"shade90"

---@alias LiqUI_DesignControlKindId "menuRow"|"buttonPrimary"|"buttonSecondary"|"input"

---@class LiqUI_DesignControlKindMap
---@field rest LiqUI_DesignScaleKey
---@field hover LiqUI_DesignScaleKey
---@field pressed LiqUI_DesignScaleKey
---@field selected LiqUI_DesignScaleKey?
---@field selectedHover LiqUI_DesignScaleKey?
---@field focused LiqUI_DesignScaleKey?
---@field disabled LiqUI_DesignScaleKey?

---@class LiqUI_DesignControlState
---@field enabled boolean
---@field over boolean
---@field down boolean
---@field selected boolean?
---@field focused boolean?

---@class LiqUI_Design
---@field scale LiqUI_DesignScale
---@field controlKinds table<LiqUI_DesignControlKindId, LiqUI_DesignControlKindMap>
---@field listeners function[]

---@class LiqUI_DesignColorBinding
---@field texture Texture
---@field color ColorMixin

---@alias LiqUI_DesignSandboxPageId "colors"|"input"

---@class LiqUI_DesignSandboxTitlebar : Frame
---@field title FontString
---@field CloseButton Button

---@class LiqUI_DesignSandboxControl : Button, EditBox, BackdropTemplate
---@field controlKind LiqUI_DesignControlKindId
---@field selected boolean?
---@field focused boolean?
---@field Fill Texture
---@field IsOver fun(self: LiqUI_DesignSandboxControl): boolean?
---@field IsDown fun(self: LiqUI_DesignSandboxControl): boolean?

---@class LiqUI_DesignSandboxMenu : Frame
---@field colorsRow LiqUI_DesignSandboxControl
---@field inputRow LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxColorsPage : Frame
---@field primarySwatch Frame
---@field primaryLabel FontString
---@field primaryButton LiqUI_DesignSandboxControl
---@field secondaryButton LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxInputPage : Frame
---@field heading FontString
---@field nameInput LiqUI_DesignSandboxControl
---@field emptyInput LiqUI_DesignSandboxControl
---@field disabledInput LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxBody : Frame
---@field colorsPage LiqUI_DesignSandboxColorsPage
---@field inputPage LiqUI_DesignSandboxInputPage

---@class LiqUI_DesignSandbox : BackdropTemplate
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
