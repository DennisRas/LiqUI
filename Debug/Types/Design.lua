---@class LiqUI_DesignDB
---@field primary ColorTable
---@field point LiqUI_WindowPointPersisted?

---@class LiqUI_DesignColors
---@field primary ColorMixin
---@field white ColorMixin
---@field grey ColorMixin
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
---@field shade5 ColorMixin
---@field shade10 ColorMixin
---@field shade15 ColorMixin
---@field shade20 ColorMixin
---@field shade25 ColorMixin
---@field shade30 ColorMixin
---@field shade35 ColorMixin
---@field shade40 ColorMixin
---@field shade45 ColorMixin
---@field shade50 ColorMixin
---@field shade55 ColorMixin
---@field shade60 ColorMixin
---@field shade65 ColorMixin
---@field shade70 ColorMixin
---@field shade75 ColorMixin
---@field shade80 ColorMixin
---@field shade85 ColorMixin
---@field shade90 ColorMixin
---@field shade95 ColorMixin

---@alias LiqUI_DesignColorKey "primary"|"white"|"grey"|"black"|"tint5"|"tint10"|"tint15"|"tint20"|"tint25"|"tint30"|"tint35"|"tint40"|"tint45"|"tint50"|"shade5"|"shade10"|"shade15"|"shade20"|"shade25"|"shade30"|"shade35"|"shade40"|"shade45"|"shade50"|"shade55"|"shade60"|"shade65"|"shade70"|"shade75"|"shade80"|"shade85"|"shade90"|"shade95"

---@class LiqUI_DesignBackground
---@field normal LiqUI_DesignColorKey
---@field hover LiqUI_DesignColorKey?
---@field pressed LiqUI_DesignColorKey?
---@field disabled LiqUI_DesignColorKey?
---@field selected LiqUI_DesignColorKey?
---@field alt LiqUI_DesignColorKey?

---@class LiqUI_DesignBorder
---@field size number
---@field color LiqUI_DesignColorKey?
---@field hover LiqUI_DesignColorKey?
---@field pressed LiqUI_DesignColorKey?
---@field focus LiqUI_DesignColorKey?
---@field disabled LiqUI_DesignColorKey?
---@field selected LiqUI_DesignColorKey?

---@class LiqUI_DesignText
---@field normal LiqUI_DesignColorKey
---@field hover LiqUI_DesignColorKey?
---@field pressed LiqUI_DesignColorKey?
---@field disabled LiqUI_DesignColorKey?
---@field selected LiqUI_DesignColorKey?

---@class LiqUI_DesignAccent
---@field size number
---@field color LiqUI_DesignColorKey

---@class LiqUI_DesignElement
---@field width number|string?
---@field height number|string?
---@field padding number?
---@field gap number?
---@field alpha number?
---@field textInsets number?
---@field round boolean?
---@field background LiqUI_DesignBackground?
---@field border LiqUI_DesignBorder?
---@field text LiqUI_DesignText?
---@field accent LiqUI_DesignAccent?

---@class LiqUI_DesignElementState
---@field enabled boolean
---@field over boolean
---@field down boolean
---@field selected boolean?
---@field focused boolean?
---@field alt boolean?

---@class LiqUI_DesignSquareBorder
---@field Top Texture
---@field Bottom Texture
---@field Left Texture
---@field Right Texture

---@class LiqUI_DesignMixin : Frame
---@field tokens LiqUI_DesignElement
---@field allowHighlight boolean?
---@field selected boolean?
---@field focused boolean?
---@field previewOver boolean?
---@field previewDown boolean?
---@field alt boolean?
---@field Background Texture?
---@field Border Texture?
---@field SquareBorder LiqUI_DesignSquareBorder?
---@field AccentClip Frame?
---@field Accent Texture?
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
---@field duration number

---@class LiqUI_DesignVertexColorAnim
---@field SetDuration fun(self: LiqUI_DesignVertexColorAnim, durationSec: number)
---@field SetSmoothing fun(self: LiqUI_DesignVertexColorAnim, weights: string)
---@field SetStartColor fun(self: LiqUI_DesignVertexColorAnim, color: ColorMixin)
---@field SetEndColor fun(self: LiqUI_DesignVertexColorAnim, color: ColorMixin)

---@class LiqUI_DesignColorAnim
---@field group AnimationGroup
---@field anim LiqUI_DesignVertexColorAnim
---@field from ColorMixin
---@field to ColorMixin

---@class LiqUI_Design
---@field colors LiqUI_DesignColors
---@field element LiqUI_DesignRecipe
---@field typography table<LiqUI_DesignTypeId, LiqUI_DesignTypeStyle>
---@field layout LiqUI_DesignLayout
---@field window LiqUI_DesignWindow
---@field panel LiqUI_DesignPanel
---@field button LiqUI_DesignButton
---@field input LiqUI_DesignElement
---@field table LiqUI_DesignTable
---@field Mixin LiqUI_DesignMixin
---@field listeners function[]
---@field fontFile string
---@field fontFlags string
---@field snapPaint boolean?

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
---@field titlebar LiqUI_DesignWindowTitlebar
---@field menu LiqUI_DesignWindowMenu
---@field body LiqUI_DesignWindowBody
---@field overlay LiqUI_DesignElement

---@class LiqUI_DesignPanelHeader : LiqUI_DesignElement
---@field height number
---@field padding number

---@class LiqUI_DesignPanel : LiqUI_DesignElement
---@field padding number
---@field background LiqUI_DesignBackground
---@field header LiqUI_DesignPanelHeader
---@field maxHeight number?

---@class LiqUI_DesignButton
---@field primary LiqUI_DesignElement
---@field secondary LiqUI_DesignElement

---@class LiqUI_DesignTable : LiqUI_DesignElement
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

---@class LiqUI_DesignSandboxWindowOptions
---@field showOverlay boolean?
---@field overlayAlpha number?
---@field bodyBackground LiqUI_DesignColorKey?

---@class LiqUI_DesignSandboxPanelOptions
---@field title string?
---@field text string?
---@field padding number?
---@field maxHeight number?
---@field showBackground boolean?
---@field showBorder boolean?
---@field showHeaderBackground boolean?
---@field background LiqUI_DesignColorKey?
---@field borderColor LiqUI_DesignColorKey?
---@field headerBackground LiqUI_DesignColorKey?

---@class LiqUI_DesignSandboxPanelSample
---@field frame LiqUI_DesignSandboxElement
---@field header LiqUI_DesignSandboxElement?
---@field body Frame
---@field scrollBox LiqUI_ScrollBox?

---@class LiqUI_DesignTableOptions
---@field showBorder boolean?
---@field highlightRows boolean?
---@field highlightHeader boolean?
---@field stripes boolean?

---@class LiqUI_DesignTableRowOptions
---@field highlight boolean?
---@field inset number?
---@field alt boolean?

---@alias LiqUI_DesignSandboxPageId "colors"|"window"|"panel"|"table"|"buttons"|"input"|"text"

---@class LiqUI_DesignSandboxTitlebar : LiqUI_DesignSandboxElement
---@field title FontString
---@field CloseButton LiqUI_DesignSandboxElement

---@class LiqUI_DesignSandboxElement : Button, EditBox, LiqUI_DesignMixin
---@field IsOver fun(self: LiqUI_DesignSandboxElement): boolean?
---@field IsDown fun(self: LiqUI_DesignSandboxElement): boolean?

---@class LiqUI_DesignSandboxMenu : LiqUI_DesignSandboxElement
---@field colorsRow LiqUI_DesignSandboxElement
---@field windowRow LiqUI_DesignSandboxElement
---@field panelRow LiqUI_DesignSandboxElement
---@field tableRow LiqUI_DesignSandboxElement
---@field buttonsRow LiqUI_DesignSandboxElement
---@field inputRow LiqUI_DesignSandboxElement
---@field textRow LiqUI_DesignSandboxElement

---@class LiqUI_DesignSandboxColorsPage : Frame
---@field primarySwatch Frame
---@field primaryLabel FontString

---@class LiqUI_DesignSandboxWindowPage : Frame
---@field heading FontString
---@field scrollBox LiqUI_ScrollBox

---@class LiqUI_DesignSandboxPanelPage : Frame
---@field heading FontString
---@field scrollBox LiqUI_ScrollBox

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
---@field panelPage LiqUI_DesignSandboxPanelPage
---@field tablePage LiqUI_DesignSandboxTablePage
---@field buttonsPage LiqUI_DesignSandboxButtonsPage
---@field inputPage LiqUI_DesignSandboxInputPage
---@field textPage LiqUI_DesignSandboxTextPage

---@class LiqUI_DesignSandbox : LiqUI_DesignSandboxElement
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
