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

---@class LiqUI_DesignStyle
---@field rest LiqUI_DesignScaleKey
---@field selected LiqUI_DesignScaleKey?
---@field disabled LiqUI_DesignScaleKey?
---@field alt LiqUI_DesignScaleKey?
---@field height number?
---@field width number?
---@field gap number?
---@field hover boolean?
---@field press boolean?
---@field hoverWash number?
---@field pressWash number?
---@field borderPixels number?
---@field borderTint number?
---@field activeBorder boolean?
---@field borderRest LiqUI_DesignScaleKey?
---@field borderFocus LiqUI_DesignScaleKey?
---@field fillLayer DrawLayer?
---@field textInset number?

---@class LiqUI_DesignControlState
---@field enabled boolean
---@field over boolean
---@field down boolean
---@field selected boolean?
---@field focused boolean?
---@field alt boolean?

---@alias LiqUI_DesignTypeId "h1"|"h2"|"h3"|"title"|"p"|"label"

---@class LiqUI_DesignTypeStyle
---@field size number
---@field spacing number?
---@field flags string?
---@field wrap boolean?
---@field color LiqUI_DesignScaleKey
---@field file string?
---@field fontObject Font?

---@class LiqUI_Design
---@field scale LiqUI_DesignScale
---@field typography table<LiqUI_DesignTypeId, LiqUI_DesignTypeStyle>
---@field layout LiqUI_DesignLayout
---@field window LiqUI_DesignWindow
---@field menu LiqUI_DesignMenu
---@field titlebar LiqUI_DesignTitlebar
---@field button LiqUI_DesignButton
---@field input LiqUI_DesignStyle
---@field table LiqUI_DesignTable
---@field listeners function[]
---@field fontFile string
---@field fontFlags string
---@field activeBorderColor ColorMixin?

---@class LiqUI_DesignLayout
---@field padding number
---@field gap number
---@field sectionGap number
---@field scrollBar number
---@field swatchSize number
---@field swatchGap number

---@class LiqUI_DesignWindow
---@field width number
---@field height number
---@field titlebarHeight number
---@field menuWidth number
---@field overlayAlpha number
---@field sampleHeight number
---@field borderPixels number
---@field fill LiqUI_DesignScaleKey
---@field border LiqUI_DesignScaleKey
---@field titlebar LiqUI_DesignScaleKey
---@field menu LiqUI_DesignScaleKey
---@field body LiqUI_DesignScaleKey

---@class LiqUI_DesignMenu
---@field row LiqUI_DesignStyle

---@class LiqUI_DesignTitlebar
---@field button LiqUI_DesignStyle

---@class LiqUI_DesignButton
---@field primary LiqUI_DesignStyle
---@field secondary LiqUI_DesignStyle

---@class LiqUI_DesignTable
---@field fill LiqUI_DesignScaleKey
---@field border LiqUI_DesignScaleKey
---@field borderPixels number
---@field cellPad number
---@field rowHeight number
---@field showBorder boolean
---@field hoverRows boolean
---@field headerHover boolean
---@field header LiqUI_DesignStyle
---@field row LiqUI_DesignStyle

---@class LiqUI_DesignElementOptions
---@field width number|string?
---@field height number|string?

---@class LiqUI_DesignSizeBinding
---@field region Region
---@field width number|string?
---@field height number|string?

---@class LiqUI_DesignStackOptions
---@field padding number?
---@field gap number?
---@field onLayout function?

---@class LiqUI_DesignStack
---@field parent Frame
---@field padding number?
---@field gap number
---@field regions Region[]
---@field onLayout function?

---@class LiqUI_DesignColorBinding
---@field texture Texture
---@field color ColorMixin

---@class LiqUI_DesignTypeSample
---@field fontString FontString
---@field typeId LiqUI_DesignTypeId

---@class LiqUI_DesignSandboxWindowSample
---@field frame BackdropTemplate|Frame
---@field titlebar Frame
---@field body Frame
---@field overlay Frame?

---@class LiqUI_DesignTableOptions
---@field showBorder boolean?
---@field hoverRows boolean?
---@field headerHover boolean?

---@class LiqUI_DesignTableRowOptions
---@field hover boolean?
---@field inset number?
---@field alt boolean?

---@class LiqUI_DesignSandboxTableSample
---@field frame BackdropTemplate|Frame
---@field showBorder boolean

---@alias LiqUI_DesignSandboxPageId "colors"|"window"|"table"|"buttons"|"input"|"text"

---@class LiqUI_DesignSandboxTitlebar : Frame
---@field title FontString
---@field CloseButton Button

---@class LiqUI_DesignSandboxControl : Button, EditBox, BackdropTemplate
---@field style LiqUI_DesignStyle
---@field selected boolean?
---@field focused boolean?
---@field previewOver boolean?
---@field previewDown boolean?
---@field hover boolean?
---@field alt boolean?
---@field cells FontString[]?
---@field Fill Texture
---@field Wash Texture
---@field Instructions FontString?
---@field IsOver fun(self: LiqUI_DesignSandboxControl): boolean?
---@field IsDown fun(self: LiqUI_DesignSandboxControl): boolean?

---@class LiqUI_DesignSandboxMenu : Frame
---@field colorsRow LiqUI_DesignSandboxControl
---@field windowRow LiqUI_DesignSandboxControl
---@field tableRow LiqUI_DesignSandboxControl
---@field buttonsRow LiqUI_DesignSandboxControl
---@field inputRow LiqUI_DesignSandboxControl
---@field textRow LiqUI_DesignSandboxControl

---@class LiqUI_DesignSandboxColorsPage : Frame
---@field primarySwatch Frame
---@field primaryLabel FontString

---@class LiqUI_DesignSandboxWindowPage : Frame
---@field heading FontString

---@class LiqUI_DesignSandboxTablePage : Frame
---@field heading FontString
---@field scrollBox LiqUI_ScrollBox

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
---@field windowPage LiqUI_DesignSandboxWindowPage
---@field tablePage LiqUI_DesignSandboxTablePage
---@field buttonsPage LiqUI_DesignSandboxButtonsPage
---@field inputPage LiqUI_DesignSandboxInputPage
---@field textPage LiqUI_DesignSandboxTextPage

---@class LiqUI_DesignSandbox : BackdropTemplate
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
