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

---@class LiqUI_DesignTokens
---@field surface ColorMixin
---@field surfaceRaised ColorMixin
---@field border ColorMixin
---@field accent ColorMixin
---@field accentHover ColorMixin
---@field accentPressed ColorMixin
---@field text ColorMixin
---@field textMuted ColorMixin

---@class LiqUI_Design
---@field scale LiqUI_DesignScale
---@field tokens LiqUI_DesignTokens
---@field tokenScaleKeys table<string, string>
---@field listeners function[]

---@class LiqUI_DesignColorBinding
---@field texture Texture
---@field color ColorMixin

---@class LiqUI_DesignSandboxTitlebar : Frame
---@field title FontString
---@field CloseButton Button

---@class LiqUI_DesignSandboxMenu : Frame
---@field colorsRow Button

---@class LiqUI_DesignSandboxBody : Frame
---@field primarySwatch Frame
---@field primaryLabel FontString

---@class LiqUI_DesignSandbox : Frame
---@field titlebar LiqUI_DesignSandboxTitlebar
---@field menu LiqUI_DesignSandboxMenu
---@field body LiqUI_DesignSandboxBody
