---@class LiqUI_DesignDB
---@field primary ColorTable
---@field point LiqUI_WindowPointPersisted?

---@class LiqUI_DesignColors
---@field primary ColorMixin
---@field white ColorMixin
---@field black ColorMixin
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

---@alias LiqUI_DesignColorKey "primary"|"white"|"black"|"tint5"|"tint10"|"tint15"|"tint20"|"tint25"|"tint30"|"tint35"|"tint40"|"tint45"|"tint50"|"shade10"|"shade20"|"shade30"|"shade40"|"shade50"|"shade60"|"shade70"|"shade80"|"shade90"

---@class LiqUI_DesignBackground
---@field normal LiqUI_DesignColorKey
---@field disabled LiqUI_DesignColorKey?
---@field selected LiqUI_DesignColorKey?
---@field alt LiqUI_DesignColorKey?

---@class LiqUI_DesignBorder
---@field size number
---@field color LiqUI_DesignColorKey?
---@field focus LiqUI_DesignColorKey?
---@field highlightTint number?

---@class LiqUI_DesignOverlay
---@field color LiqUI_DesignColorKey
---@field alpha number

---@alias LiqUI_DesignOverlaySpec boolean|LiqUI_DesignOverlay

---@class LiqUI_DesignElement
---@field width number|string?
---@field height number|string?
---@field padding number?
---@field gap number?
---@field alpha number?
---@field textInsets number?
---@field background LiqUI_DesignBackground
---@field border LiqUI_DesignBorder?
---@field highlight LiqUI_DesignOverlaySpec?
---@field pushed LiqUI_DesignOverlaySpec?

---@class LiqUI_DesignElementState
---@field enabled boolean
---@field over boolean
---@field down boolean
---@field selected boolean?
---@field focused boolean?
---@field alt boolean?

---@class LiqUI_DesignMixin
---@field tokens LiqUI_DesignElement
---@field allowHighlight boolean?
---@field selected boolean?
---@field focused boolean?
---@field previewOver boolean?
---@field previewDown boolean?
---@field alt boolean?
---@field Background Texture
---@field Highlight Texture
---@field Instructions FontString?
---@field cells FontString[]?

---@alias LiqUI_DesignTypeId "h1"|"h2"|"h3"|"title"|"p"|"label"

---@class LiqUI_DesignTypeStyle
---@field size number
---@field spacing number?
---@field flags string?
---@field wrap boolean?
---@field color LiqUI_DesignColorKey
---@field file string?
---@field fontObject Font?

---@class LiqUI_DesignRecipe
---@field border LiqUI_DesignBorder
---@field highlight LiqUI_DesignOverlay
---@field pushed LiqUI_DesignOverlay

---@class LiqUI_Design
---@field colors LiqUI_DesignColors
---@field element LiqUI_DesignRecipe
---@field typography table<LiqUI_DesignTypeId, LiqUI_DesignTypeStyle>
---@field layout LiqUI_DesignLayout
---@field window LiqUI_DesignWindow
---@field button LiqUI_DesignButton
---@field input LiqUI_DesignElement
---@field table LiqUI_DesignTable
---@field Mixin LiqUI_DesignMixin
---@field listeners function[]
---@field fontFile string
---@field fontFlags string
---@field borderMixColor ColorMixin?

---@class LiqUI_DesignLayout
---@field gap number
---@field sectionGap number
---@field scrollBar number
---@field swatchSize number
---@field swatchGap number

---@class LiqUI_DesignWindowTitlebar : LiqUI_DesignElement
---@field button LiqUI_DesignElement

---@class LiqUI_DesignWindowMenu : LiqUI_DesignElement
---@field padding number
---@field row LiqUI_DesignElement

---@class LiqUI_DesignWindowBody : LiqUI_DesignElement
---@field padding number

---@class LiqUI_DesignWindow : LiqUI_DesignElement
---@field border LiqUI_DesignBorder
---@field titlebar LiqUI_DesignWindowTitlebar
---@field menu LiqUI_DesignWindowMenu
---@field body LiqUI_DesignWindowBody
---@field overlay LiqUI_DesignElement

---@class LiqUI_DesignButton
---@field primary LiqUI_DesignElement
---@field secondary LiqUI_DesignElement

---@class LiqUI_DesignTable : LiqUI_DesignElement
---@field border LiqUI_DesignBorder
---@field cellPadding number
---@field rowHeight number
---@field highlightRows boolean
---@field highlightHeader boolean
---@field header LiqUI_DesignElement
---@field row LiqUI_DesignElement

---@class LiqUI_DesignSizeOptions
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
---@field frame LiqUI_DesignSandboxElement
---@field titlebar LiqUI_DesignSandboxElement
---@field body LiqUI_DesignSandboxElement
---@field overlay LiqUI_DesignSandboxElement?

---@class LiqUI_DesignTableOptions
---@field showBorder boolean?
---@field highlightRows boolean?
---@field highlightHeader boolean?

---@class LiqUI_DesignTableRowOptions
---@field highlight boolean?
---@field inset number?
---@field alt boolean?

---@alias LiqUI_DesignSandboxPageId "colors"|"window"|"table"|"buttons"|"input"|"text"

---@class LiqUI_DesignSandboxTitlebar : LiqUI_DesignSandboxElement
---@field title FontString
---@field CloseButton LiqUI_DesignSandboxElement

---@class LiqUI_DesignSandboxElement : Button, EditBox, BackdropTemplate, LiqUI_DesignMixin
---@field IsOver fun(self: LiqUI_DesignSandboxElement): boolean?
---@field IsDown fun(self: LiqUI_DesignSandboxElement): boolean?

---@class LiqUI_DesignSandboxMenu : LiqUI_DesignSandboxElement
---@field colorsRow LiqUI_DesignSandboxElement
---@field windowRow LiqUI_DesignSandboxElement
---@field tableRow LiqUI_DesignSandboxElement
---@field buttonsRow LiqUI_DesignSandboxElement
---@field inputRow LiqUI_DesignSandboxElement
---@field textRow LiqUI_DesignSandboxElement

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
---@field nameInput LiqUI_DesignSandboxElement
---@field emptyInput LiqUI_DesignSandboxElement
---@field disabledInput LiqUI_DesignSandboxElement

---@class LiqUI_DesignSandboxTextPage : Frame
---@field scrollBox LiqUI_ScrollBox

---@class LiqUI_DesignSandboxBody : LiqUI_DesignSandboxElement
---@field colorsPage LiqUI_DesignSandboxColorsPage
---@field windowPage LiqUI_DesignSandboxWindowPage
---@field tablePage LiqUI_DesignSandboxTablePage
---@field buttonsPage LiqUI_DesignSandboxButtonsPage
---@field inputPage LiqUI_DesignSandboxInputPage
---@field textPage LiqUI_DesignSandboxTextPage

---@class LiqUI_DesignSandbox : LiqUI_DesignSandboxElement
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
