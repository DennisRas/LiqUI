---@class LiqUI_DesignDB
---@field primary ColorTable
---@field point LiqUI_WindowPointPersisted?

---@class LiqUI_DesignScale
---@field primary ColorMixin
---@field white ColorMixin
---@field tint5 ColorMixin
---@field tint10 ColorMixin
---@field tint15 ColorMixin
---@field tint20 ColorMixin
---@field tint25 ColorMixin
---@field tint30 ColorMixin
---@field tint35 ColorMixin
---@field tint40 ColorMixin
---@field tint45 ColorMixin
---@field tint50 ColorMixin
---@field shade10 ColorMixin
---@field shade20 ColorMixin
---@field shade30 ColorMixin
---@field shade40 ColorMixin
---@field shade50 ColorMixin
---@field shade60 ColorMixin
---@field shade70 ColorMixin
---@field shade80 ColorMixin
---@field shade90 ColorMixin

---@alias LiqUI_DesignScaleKey "primary"|"white"|"tint5"|"tint10"|"tint15"|"tint20"|"tint25"|"tint30"|"tint35"|"tint40"|"tint45"|"tint50"|"shade10"|"shade20"|"shade30"|"shade40"|"shade50"|"shade60"|"shade70"|"shade80"|"shade90"

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

---@alias LiqUI_DesignTypeId "h1"|"h2"|"h3"|"p"|"label"

---@class LiqUI_DesignTypeStyle
---@field fontObject string
---@field color LiqUI_DesignScaleKey
---@field wrap boolean?

---@class LiqUI_Design
---@field scale LiqUI_DesignScale
---@field typography table<LiqUI_DesignTypeId, LiqUI_DesignTypeStyle>
---@field controlKinds table<LiqUI_DesignControlKindId, LiqUI_DesignControlKindMap>
---@field listeners function[]

---@class LiqUI_DesignColorBinding
---@field texture Texture
---@field color ColorMixin

---@class LiqUI_DesignTypeSample
---@field fontString FontString
---@field typeId LiqUI_DesignTypeId

---@alias LiqUI_DesignSandboxPageId "colors"|"buttons"|"input"|"text"

---@class LiqUI_DesignSandboxTitlebar : Frame
---@field title FontString
---@field CloseButton Button

---@class LiqUI_DesignSandboxControl : Button, EditBox, BackdropTemplate
---@field controlKind LiqUI_DesignControlKindId
---@field selected boolean?
---@field focused boolean?
---@field previewOver boolean?
---@field previewDown boolean?
---@field Fill Texture
---@field Instructions FontString?
---@field IsOver fun(self: LiqUI_DesignSandboxControl): boolean?
---@field IsDown fun(self: LiqUI_DesignSandboxControl): boolean?

---@class LiqUI_DesignSandboxMenu : Frame
---@field colorsRow LiqUI_DesignSandboxControl
---@field buttonsRow LiqUI_DesignSandboxControl
---@field inputRow LiqUI_DesignSandboxControl
---@field textRow LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxColorsPage : Frame
---@field primarySwatch Frame
---@field primaryLabel FontString

---@class LiqUI_DesignSandboxButtonsPage : Frame
---@field heading FontString

---@class LiqUI_DesignSandboxInputPage : Frame
---@field heading FontString
---@field nameInput LiqUI_DesignSandboxControl
---@field emptyInput LiqUI_DesignSandboxControl
---@field disabledInput LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxTextPage : Frame
---@field scrollBox LiqUI_ScrollBox

---@class LiqUI_DesignSandboxBody : Frame
---@field colorsPage LiqUI_DesignSandboxColorsPage
---@field buttonsPage LiqUI_DesignSandboxButtonsPage
---@field inputPage LiqUI_DesignSandboxInputPage
---@field textPage LiqUI_DesignSandboxTextPage

---@class LiqUI_DesignSandbox : BackdropTemplate
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
