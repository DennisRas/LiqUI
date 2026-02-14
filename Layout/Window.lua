local C = LiqUI.Config

local WindowDefaults = {
  parent = UIParent,
  name = "",
  title = "",
  borderSize = 2,
  titlebar = true,
  windowScale = 100,
  windowColor = { r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1 },
  point = { "CENTER" },
  icon = nil,
  backdropTexture = C.shared.backdropTexture,
  titlebarHeight = C.window.titlebarHeight,
  padding = C.window.padding,
  titlebarIconLeft = C.window.titlebarIconLeft,
  titlebarIconSize = C.window.titlebarIconSize,
  closeButtonIconSize = C.window.closeButtonIconSize,
  closeButtonIconColor = C.window.closeButtonIconColor,
  iconCloseTexture = C.window.iconCloseTexture,
  maxWindowWidthMargin = C.window.maxWindowWidthMargin,
  width = 300,
  height = 300,
  frameLevel = 3000,
  frameStrata = "MEDIUM",
  setToplevel = true,
  movable = true,
  enableMouse = true,
  clampedToScreen = true,
}

---@type table<string, LiqUI_WindowFrame>
local WindowCollection = {}

local Window = {}
LiqUI.Window = Window

---Create a window frame (titlebar + empty body)
---@param options LiqUI_WindowOptions
---@return LiqUI_WindowFrame
function Window:New(options)
  local name = "LiqUIWindow" .. LiqUI.Utils.TableCount(WindowCollection) + 1
  local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
  frame.options = LiqUI.Utils.PrepareOptions(WindowDefaults, options or {})
  frame:SetFrameStrata(frame.options.frameStrata)
  frame:SetFrameLevel(frame.options.frameLevel)
  frame:SetToplevel(frame.options.setToplevel)
  frame:SetMovable(frame.options.movable)
  frame:SetPoint(unpack(frame.options.point))
  frame:SetSize(frame.options.width, frame.options.height)
  frame:EnableMouse(frame.options.enableMouse)
  frame:SetParent(frame.options.parent)
  frame:SetClampedToScreen(frame.options.clampedToScreen)
  frame:SetClampRectInsets(frame:GetWidth() / 2, frame:GetWidth() / -2, 0, frame:GetHeight() / 2)
  frame:SetScript("OnSizeChanged", function()
    frame:SetClampRectInsets(frame:GetWidth() / 2, frame:GetWidth() / -2, 0, frame:GetHeight() / 2)
  end)

  frame:SetBackdrop({
    bgFile = frame.options.backdropTexture,
    edgeFile = frame.options.backdropTexture,
    tile = true,
    tileSize = 8,
    edgeSize = frame.options.borderSize,
    insets = { left = frame.options.borderSize, right = frame.options.borderSize, top = frame.options.borderSize, bottom = frame.options.borderSize },
  })
  frame:SetBackdropColor(frame.options.windowColor.r, frame.options.windowColor.g, frame.options.windowColor.b,
    frame.options.windowColor.a)
  frame:SetBackdropBorderColor(0, 0, 0, 0.5)

  if frame.options.titlebar then
    frame.titlebar = CreateFrame("Frame", "$parentTitleBar", frame, "BackdropTemplate")
    frame.titlebar:EnableMouse(true)
    frame.titlebar:RegisterForDrag("LeftButton")
    frame.titlebar:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.titlebar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    frame.titlebar:SetPoint("TOPLEFT", frame, "TOPLEFT", frame.options.borderSize, -frame.options.borderSize)
    frame.titlebar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -frame.options.borderSize, -frame.options.borderSize)
    frame.titlebar:SetHeight(frame.options.titlebarHeight)
    frame.titlebar:SetBackdrop({
      bgFile = frame.options.backdropTexture,
      edgeFile = frame.options.backdropTexture,
      edgeSize = frame.options.borderSize,
      insets = { left = 0, right = 0, top = 0, bottom = 1 },
    })
    frame.titlebar:SetBackdropColor(0, 0, 0, 0.5)
    frame.titlebar:SetBackdropBorderColor(0, 0, 0, 0.3)

    if frame.options.icon then
      frame.titlebar.iconTexture = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
      frame.titlebar.iconTexture:SetPoint("LEFT", frame.titlebar, "LEFT", frame.options.titlebarIconLeft, 0)
      frame.titlebar.iconTexture:SetSize(frame.options.titlebarIconSize, frame.options.titlebarIconSize)
      frame.titlebar.iconTexture:SetTexture(frame.options.icon)
      frame.options.padding = frame.options.titlebarIconSize + frame.options.padding
    end

    frame.titlebar.titleFontString = frame.titlebar:CreateFontString("$parentTitleFontString", "OVERLAY")
    frame.titlebar.titleFontString:SetPoint("LEFT", frame.titlebar, "LEFT", frame.options.padding, 0)
    frame.titlebar.titleFontString:SetFontObject("SystemFont_Med3")
    frame.titlebar.titleFontString:SetText(frame.options.title or frame.options.name)

    frame.titlebar.closeButton = CreateFrame("Button", "$parentCloseButton", frame.titlebar, "BackdropTemplate")
    frame.titlebar.closeButton:SetPoint("RIGHT", frame.titlebar, "RIGHT", 0, 0)
    frame.titlebar.closeButton:SetSize(frame.options.titlebarHeight, frame.options.titlebarHeight)
    frame.titlebar.closeButton:SetBackdrop({ bgFile = frame.options.backdropTexture, tile = true, tileSize = 8 })
    frame.titlebar.closeButton:SetBackdropColor(1, 1, 1, 0)
    frame.titlebar.closeButton:RegisterForClicks("AnyUp")
    frame.titlebar.closeButton:SetScript("OnClick", function() frame:Hide() end)
    frame.titlebar.closeButton.Icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    frame.titlebar.closeButton.Icon:SetPoint("CENTER", frame.titlebar.closeButton, "CENTER")
    frame.titlebar.closeButton.Icon:SetSize(frame.options.closeButtonIconSize, frame.options.closeButtonIconSize)
    frame.titlebar.closeButton.Icon:SetTexture(frame.options.iconCloseTexture)
    frame.titlebar.closeButton.Icon:SetVertexColor(frame.options.closeButtonIconColor[1],
      frame.options.closeButtonIconColor[2], frame.options.closeButtonIconColor[3], frame.options.closeButtonIconColor
      [4])
    frame.titlebar.closeButton:SetScript("OnEnter", function()
      frame.titlebar.closeButton.Icon:SetVertexColor(1, 1, 1, 1)
      frame.titlebar.closeButton:SetBackdropColor(1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(frame.titlebar.closeButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    frame.titlebar.closeButton:SetScript("OnLeave", function()
      frame.titlebar.closeButton.Icon:SetVertexColor(frame.options.closeButtonIconColor[1],
        frame.options.closeButtonIconColor[2], frame.options.closeButtonIconColor[3],
        frame.options.closeButtonIconColor[4])
      frame.titlebar.closeButton:SetBackdropColor(1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = frame.options.titlebar and -(frame.options.borderSize + frame.options.titlebarHeight) or
  -frame.options.borderSize

  frame.body = CreateFrame("Frame", "$parentBody", frame, "BackdropTemplate")
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", frame.options.borderSize, topOffset)
  frame.body:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -frame.options.borderSize, topOffset)
  frame.body:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", frame.options.borderSize, frame.options.borderSize)
  frame.body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -frame.options.borderSize, frame.options.borderSize)
  frame.body:SetBackdrop({ bgFile = frame.options.backdropTexture, tile = true, tileSize = 8 })
  frame.body:SetBackdropColor(0, 0, 0, 0)

  function frame:Toggle(state)
    if state == nil then state = not self:IsVisible() end
    self:SetShown(state)
  end

  function frame:SetTitle(title)
    if not self.config.titlebar then return end
    self.titlebar.titleFontString:SetText(title)
  end

  function frame:SetBodySize(width, height)
    local h = self.config.titlebar and (height + self.config.titlebarHeight) or height
    self:SetSize(width, h)
  end

  frame:Hide()
  table.insert(UISpecialFrames, frame:GetName())
  if frame.options.name and frame.options.name ~= "" then
    WindowCollection[frame.options.name] = frame
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
  return GetScreenWidth() - WindowDefaults.maxWindowWidthMargin
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
