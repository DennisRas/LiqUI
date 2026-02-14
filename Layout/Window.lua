local TITLEBAR_HEIGHT = 30
local BORDER = 4
local PADDING = 8
local BG_TEXTURE = "Interface/BUTTONS/WHITE8X8"
local ICON_CLOSE = "Interface/AddOns/LiqUI/Media/Icon_Close.blp"

---@type table<string, LiqUI_WindowFrame>
local WindowCollection = {}

local Window = {}
LiqUI.Window = Window

---Create a window frame (titlebar + empty body)
---@param options LiqUI_WindowOptions
---@return LiqUI_WindowFrame
function Window:New(options)
  local frame = CreateFrame("Frame",
    "LiqUIWindow" .. (options and options.name or (LiqUI.Utils.TableCount(WindowCollection) + 1)),
    options and options.parent or UIParent, "BackdropTemplate")
  local defaults = {
    parent = UIParent,
    name = "",
    title = "",
    border = BORDER,
    titlebar = true,
    windowScale = 100,
    windowColor = { r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1 },
    point = { "CENTER" },
    icon = nil,
  }
  frame.config = LiqUI.Utils.MergeDeep(defaults, options or {})
  frame:SetFrameStrata("MEDIUM")
  frame:SetFrameLevel(3000)
  frame:SetToplevel(true)
  frame:SetMovable(true)
  frame:SetPoint(unpack(frame.config.point))
  frame:SetSize(300, 300)
  frame:EnableMouse(true)
  frame:SetParent(frame.config.parent)
  frame:SetClampedToScreen(true)
  frame:SetClampRectInsets(frame:GetWidth() / 2, frame:GetWidth() / -2, 0, frame:GetHeight() / 2)
  frame:SetScript("OnSizeChanged", function()
    frame:SetClampRectInsets(frame:GetWidth() / 2, frame:GetWidth() / -2, 0, frame:GetHeight() / 2)
  end)

  frame:SetBackdrop({
    bgFile = BG_TEXTURE,
    edgeFile = BG_TEXTURE,
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = { left = frame.config.border, right = frame.config.border, top = frame.config.border, bottom = frame.config.border },
  })
  frame:SetBackdropColor(frame.config.windowColor.r, frame.config.windowColor.g, frame.config.windowColor.b,
    frame.config.windowColor.a)
  frame:SetBackdropBorderColor(0, 0, 0, 0.5)

  if frame.config.titlebar then
    frame.titlebar = CreateFrame("Frame", "$parentTitleBar", frame, "BackdropTemplate")
    frame.titlebar:EnableMouse(true)
    frame.titlebar:RegisterForDrag("LeftButton")
    frame.titlebar:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.titlebar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    local b = frame.config.border
    frame.titlebar:SetPoint("TOPLEFT", frame, "TOPLEFT", b, -b)
    frame.titlebar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -b, -b)
    frame.titlebar:SetHeight(TITLEBAR_HEIGHT)
    frame.titlebar:SetBackdrop({
      bgFile = BG_TEXTURE,
      edgeFile = BG_TEXTURE,
      edgeSize = 8,
      insets = { left = 0, right = 0, top = 0, bottom = 1 },
    })
    frame.titlebar:SetBackdropColor(0, 0, 0, 0.5)
    frame.titlebar:SetBackdropBorderColor(0, 0, 0, 0.3)

    local titleLeftOffset = PADDING
    if frame.config.icon then
      frame.titlebar.icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
      frame.titlebar.icon:SetPoint("LEFT", frame.titlebar, "LEFT", 6, 0)
      frame.titlebar.icon:SetSize(20, 20)
      frame.titlebar.icon:SetTexture(frame.config.icon)
      titleLeftOffset = 20 + PADDING
    end

    frame.titlebar.title = frame.titlebar:CreateFontString("$parentText", "OVERLAY")
    frame.titlebar.title:SetPoint("LEFT", frame.titlebar, "LEFT", titleLeftOffset, 0)
    frame.titlebar.title:SetFontObject("SystemFont_Med3")
    frame.titlebar.title:SetText(frame.config.title or frame.config.name)

    frame.titlebar.CloseButton = CreateFrame("Button", "$parentCloseButton", frame.titlebar, "BackdropTemplate")
    frame.titlebar.CloseButton:SetPoint("RIGHT", frame.titlebar, "RIGHT", 0, 0)
    frame.titlebar.CloseButton:SetSize(TITLEBAR_HEIGHT, TITLEBAR_HEIGHT)
    frame.titlebar.CloseButton:SetBackdrop({ bgFile = BG_TEXTURE, tile = true, tileSize = 8 })
    frame.titlebar.CloseButton:SetBackdropColor(1, 1, 1, 0)
    frame.titlebar.CloseButton:RegisterForClicks("AnyUp")
    frame.titlebar.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    frame.titlebar.CloseButton.Icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    frame.titlebar.CloseButton.Icon:SetPoint("CENTER", frame.titlebar.CloseButton, "CENTER")
    frame.titlebar.CloseButton.Icon:SetSize(10, 10)
    frame.titlebar.CloseButton.Icon:SetTexture(ICON_CLOSE)
    frame.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    frame.titlebar.CloseButton:SetScript("OnEnter", function()
      frame.titlebar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      frame.titlebar.CloseButton:SetBackdropColor(1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(frame.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    frame.titlebar.CloseButton:SetScript("OnLeave", function()
      frame.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      frame.titlebar.CloseButton:SetBackdropColor(1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local b = frame.config.border
  local topOffset = frame.config.titlebar and -(b + TITLEBAR_HEIGHT) or -b

  frame.body = CreateFrame("Frame", "$parentBody", frame, "BackdropTemplate")
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", b, topOffset)
  frame.body:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -b, topOffset)
  frame.body:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", b, b)
  frame.body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -b, b)
  frame.body:SetBackdrop({ bgFile = BG_TEXTURE, tile = true, tileSize = 8 })
  frame.body:SetBackdropColor(0, 0, 0, 0)

  function frame:Toggle(state)
    if state == nil then state = not self:IsVisible() end
    self:SetShown(state)
  end

  function frame:SetTitle(title)
    if not self.config.titlebar then return end
    self.titlebar.title:SetText(title)
  end

  function frame:SetBodySize(width, height)
    local h = self.config.titlebar and (height + TITLEBAR_HEIGHT) or height
    self:SetSize(width, h)
  end

  frame:Hide()
  table.insert(UISpecialFrames, frame:GetName())
  if frame.config.name and frame.config.name ~= "" then
    WindowCollection[frame.config.name] = frame
  end
  return frame
end

---Get a window by name
---@param name string
---@return LiqUI_WindowFrame?
function Window:GetWindow(name)
  return WindowCollection[name]
end

---Scale each window
---@param scale number
function Window:SetWindowScale(scale)
  LiqUI.Utils.TableForEach(WindowCollection, function(window)
    window:SetScale(scale)
  end)
end

---Set background color to each window (uses backdrop; border color unchanged)
---@param color table
function Window:SetWindowBackgroundColor(color)
  LiqUI.Utils.TableForEach(WindowCollection, function(window)
    window:SetBackdropColor(color.r, color.g, color.b, color.a)
  end)
end

---Get maximum recommended window width (screen width minus margins)
---@return number
function Window:GetMaxWindowWidth()
  return GetScreenWidth() - 100
end

---Toggle a window's visibility by name
---@param name string?
function Window:ToggleWindow(name)
  if name == nil or name == "" then
    name = "Main"
  end
  local window = self:GetWindow(name)
  if not window then return end
  if window:IsVisible() then
    window:Hide()
  else
    window:Show()
  end
end
