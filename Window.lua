---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

local BODY_PLACEHOLDER_TEXT_INSET = 40

---@class LiqUI_WindowManager
local Window = {}
LiqUI.Window = Window

local SetBackgroundColor = LiqUI.Utils.SetBackgroundColor
local TableCopy = LiqUI.Utils.TableCopy
local TableFilter = LiqUI.Utils.TableFilter
local TableFind = LiqUI.Utils.TableFind
local TableForEach = LiqUI.Utils.TableForEach
local TableMergeConfig = LiqUI.Utils.TableMergeConfig

local function applyWindowPoint(window, point)
  if not point or type(point) ~= "table" then
    return
  end
  window:ClearAllPoints()
  local count = #point
  if count == 1 then
    window:SetPoint(point[1])
  elseif count == 4 then
    window:SetPoint(point[1], UIParent, point[2], point[3], point[4])
  elseif count >= 5 then
    window:SetPoint(unpack(point))
  end
end

local function saveWindowDb(window, db)
  if not db then
    return
  end
  local point, relativeTo, relativePoint, x, y = window:GetPoint()
  if relativeTo and relativeTo ~= UIParent then
    return
  end
  db.point = { point, relativePoint, x, y }
end

local function applyWindowDb(window, db)
  if not db then
    return
  end
  if db.windowColor then
    window.config.windowColor = db.windowColor
    SetBackgroundColor(window, db.windowColor.r, db.windowColor.g, db.windowColor.b, db.windowColor.a)
  end
  if db.scale then
    window:SetScale(db.scale / 100)
    window.config.windowScale = db.scale
  end
  if db.point then
    window.config.point = db.point
  end
end

local function repositionTitlebarButtons(window)
  if not window.titlebar or not window.titlebar.CloseButton then
    return
  end
  local anchorFrame = window.titlebar.CloseButton
  for _, titlebarButton in ipairs(window.titlebarButtons) do
    titlebarButton:SetPoint("RIGHT", anchorFrame, "LEFT", 0, 0)
    anchorFrame = titlebarButton
  end
end

---@param instance LiqUI_Instance
function Window:Embed(instance)
  instance.Window = LiqUI.BindManager(instance, self, { windows = {} })
end

---Create a window frame
---@param options LiqUI_WindowOptions
---@return LiqUI_Window
function Window:New(options)
  if not self.db then
    error("LiqUI.Window:New requires a LiqUI instance", 2)
  end
  if not options or not options.name or options.name == "" then
    error("LiqUI Window: options.name is required", 2)
  end
  local windowName = options.name
  self.db.windows[windowName] = self.db.windows[windowName] or {}
  local db = self.db.windows[windowName]
  local frameName = "LiqUIWindow" .. self.name:gsub("[^%w]", "") .. windowName:gsub("[^%w]", "")
  ---@type LiqUI_Window
  local window = CreateFrame("Frame", frameName, options.parent or UIParent)
  ---@type LiqUI_WindowOptions
  local defaultWindowOptions = {
    parent = UIParent,
    name = "",
    title = "",
    border = LiqUI.Constants.layout.sizes.border,
    titlebar = true,
    windowScale = 100,
    windowColor = LiqUI.Constants.layout.defaultWindowColor,
    point = { "CENTER" },
  }
  ---@type LiqUI_WindowOptions
  local mergedWindowOptions = {}
  TableMergeConfig(mergedWindowOptions, defaultWindowOptions)
  TableMergeConfig(mergedWindowOptions, options or {})
  window.config = mergedWindowOptions
  window.db = db
  if db and not db.windowColor then
    db.windowColor = TableCopy(window.config.windowColor)
  end
  applyWindowDb(window, db)
  window:SetFrameStrata("MEDIUM")
  window:SetFrameLevel(3000)
  window:SetToplevel(true)
  window:SetMovable(true)
  applyWindowPoint(window, window.config.point)
  window:SetSize(window.config.width or 300, window.config.height or 300)
  window:EnableMouse(true) -- Disable click-throughs
  window:SetParent(window.config.parent)
  window:SetClampedToScreen(true)
  window:SetClampRectInsets(window:GetWidth() / 2, window:GetWidth() / -2, 0, window:GetHeight() / 2)
  window:SetScript("OnSizeChanged", function()
    window:SetClampRectInsets(window:GetWidth() / 2, window:GetWidth() / -2, 0, window:GetHeight() / 2)
  end)
  SetBackgroundColor(window, window.config.windowColor.r, window.config.windowColor.g,
    window.config.windowColor.b, window.config.windowColor.a)

  ---Show or hide the window
  ---@param state boolean?
  function window:Toggle(state)
    if state == nil then
      state = not window:IsVisible()
    end
    window:SetShown(state)
  end

  ---Set the title of the window
  ---@param title string
  function window:SetTitle(title)
    if not window.config.titlebar then return end
    window.titlebar.title:SetText(title)
  end

  ---Set body size and adjust window size
  ---@param width number
  ---@param height number
  function window:SetBodySize(width, height)
    local w = width
    local h = height
    if window.config.sidebar then
      w = w + window.config.sidebar
    end
    if window.config.titlebar then
      h = h + LiqUI.Constants.layout.sizes.titlebar.height
    end
    window:SetSize(w, h)
  end

  if window.config.width and window.config.height then
    window:SetBodySize(window.config.width, window.config.height)
  end

  ---Add a button to the titlebar
  ---@param buttonConfig LiqUI_TitlebarButton
  ---@return Frame
  function window:AddTitlebarButton(buttonConfig)
    if not window.titlebar then
      error("Cannot add titlebar button: window has no titlebar")
    end

    local buttonName = buttonConfig.name
    if window.titlebarButtons[buttonName] then
      error("Button with name '" .. buttonName .. "' already exists")
    end

    local buttonSize = buttonConfig.size or LiqUI.Constants.layout.sizes.titlebar.height
    local iconSize = buttonConfig.iconSize or 12
    local isEnabled = buttonConfig.enabled ~= false

    -- Create the button frame
    local button
    if buttonConfig.setupMenu then
      -- Create dropdown button
      button = CreateFrame("DropdownButton", "$parent" .. buttonName, window.titlebar)
      local setupMenu = buttonConfig.setupMenu
      button:SetupMenu(function(_, rootMenu)
        setupMenu(window, rootMenu)
      end)
    else
      -- Create regular button
      button = CreateFrame("Button", "$parent" .. buttonName, window.titlebar)
      button:RegisterForClicks("AnyUp")
      if buttonConfig.onClick then
        button:SetScript("OnClick", buttonConfig.onClick)
      end
    end

    -- Create the icon
    button.Icon = window.titlebar:CreateTexture(button:GetName() .. "Icon", "ARTWORK")
    button.Icon:SetPoint("CENTER", button, "CENTER")
    button.Icon:SetSize(iconSize, iconSize)
    button.Icon:SetTexture(buttonConfig.icon)
    button.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)

    -- Set up tooltip
    if buttonConfig.tooltipTitle then
      button:SetScript("OnEnter", function()
        button.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(button, 1, 1, 1, 0.05)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:SetText(buttonConfig.tooltipTitle, 1, 1, 1, 1, true)
        if buttonConfig.tooltipDescription then
          GameTooltip:AddLine(buttonConfig.tooltipDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b, true)
        end
        GameTooltip:Show()
      end)

      button:SetScript("OnLeave", function()
        button.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(button, 1, 1, 1, 0)
        GameTooltip:Hide()
      end)
    end

    button:SetSize(buttonSize, buttonSize)
    button:SetEnabled(isEnabled)
    button:Show()

    -- Store the button
    table.insert(window.titlebarButtons, button)

    repositionTitlebarButtons(window)

    return button
  end

  ---Remove a button from the titlebar
  ---@param buttonName string
  function window:RemoveTitlebarButton(buttonName)
    local button = TableFind(window.titlebarButtons,
      function(button) return button:GetName() == buttonName end)
    if not button then
      error("Button with name '" .. buttonName .. "' does not exist")
    end

    -- Remove the button
    button:Hide()
    button:SetParent(nil)
    window.titlebarButtons = TableFilter(window.titlebarButtons,
      function(titlebarButton) return titlebarButton:GetName() ~= buttonName end)

    repositionTitlebarButtons(window)
  end

  ---Get a titlebar button by name
  ---@param buttonName string
  ---@return Frame?
  function window:GetTitlebarButton(buttonName)
    return TableFind(window.titlebarButtons, function(button) return button:GetName() == buttonName end)
  end

  -- Border
  if window.config.border > 0 then
    ---@diagnostic disable-next-line: assign-type-mismatch
    window.border = CreateFrame("Frame", "$parentBorder", window, "BackdropTemplate")
    window.border:SetPoint("TOPLEFT", window, "TOPLEFT", -3, 3)
    window.border:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 3, -3)
    window.border:SetBackdrop({ edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = { left = window.config.border, right = window.config.border, top = window.config.border, bottom = window.config.border } })
    window.border:SetBackdropBorderColor(0, 0, 0, .5)
    window.border:Show()
  end

  -- Titlebar
  if window.config.titlebar then
    window.titlebar = CreateFrame("Frame", "$parentTitleBar", window)
    window.titlebar:EnableMouse(true)
    window.titlebar:RegisterForDrag("LeftButton")
    window.titlebar:SetScript("OnDragStart", function() window:StartMoving() end)
    window.titlebar:SetScript("OnDragStop", function()
      window:StopMovingOrSizing()
      saveWindowDb(window, db)
    end)
    window.titlebar:SetPoint("TOPLEFT", window, "TOPLEFT")
    window.titlebar:SetPoint("TOPRIGHT", window, "TOPRIGHT")
    window.titlebar:SetHeight(LiqUI.Constants.layout.sizes.titlebar.height)
    SetBackgroundColor(window.titlebar, 0, 0, 0, 0.5)
    window.titlebar.icon = window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    window.titlebar.icon:SetPoint("LEFT", window.titlebar, "LEFT", 6, 0)
    window.titlebar.icon:SetSize(20, 20)
    if window.config.icon then
      window.titlebar.icon:SetTexture(window.config.icon)
    else
      window.titlebar.icon:Hide()
    end
    window.titlebar.title = window.titlebar:CreateFontString("$parentText", "OVERLAY")
    local titleLeft = window.config.icon and (20 + LiqUI.Constants.layout.sizes.padding) or
    LiqUI.Constants.layout.sizes.padding
    window.titlebar.title:SetPoint("LEFT", window.titlebar, "LEFT", titleLeft, 0)
    window.titlebar.title:SetFontObject("SystemFont_Med3")
    window.titlebar.title:SetText(window.config.title or window.config.name)
    window.titlebar.CloseButton = CreateFrame("Button", "$parentCloseButton", window.titlebar)
    window.titlebar.CloseButton:SetPoint("RIGHT", window.titlebar, "RIGHT", 0, 0)
    window.titlebar.CloseButton:SetSize(LiqUI.Constants.layout.sizes.titlebar.height,
      LiqUI.Constants.layout.sizes.titlebar.height)
    window.titlebar.CloseButton:RegisterForClicks("AnyUp")
    window.titlebar.CloseButton:SetScript("OnClick", function()
      window:Hide()
      if window.config.onClose then
        window.config.onClose(window)
      end
    end)
    window.titlebar.CloseButton.Icon = window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    window.titlebar.CloseButton.Icon:SetPoint("CENTER", window.titlebar.CloseButton, "CENTER")
    window.titlebar.CloseButton.Icon:SetSize(10, 10)
    window.titlebar.CloseButton.Icon:SetTexture(LiqUI.Constants.layout.media.iconClose)
    window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    window.titlebar.CloseButton:SetScript("OnEnter", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      SetBackgroundColor(window.titlebar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(window.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    window.titlebar.CloseButton:SetScript("OnLeave", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      SetBackgroundColor(window.titlebar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = 0
  local leftOffset = 0

  if window.config.titlebar then
    topOffset = -LiqUI.Constants.layout.sizes.titlebar.height
  end

  if window.config.sidebar then
    leftOffset = window.config.sidebar
  end

  -- Body
  window.body = CreateFrame("Frame", "$parentBody", window)
  window.body:SetPoint("TOPLEFT", window, "TOPLEFT", leftOffset, topOffset)
  window.body:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, topOffset)
  window.body:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", leftOffset, 0)
  window.body:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 0)
  SetBackgroundColor(window.body, 0, 0, 0, 0)

  -- Sidebar
  if window.config.sidebar then
    window.sidebar = CreateFrame("Frame", "$parentSidebar", window)
    window.sidebar:SetPoint("TOPLEFT", window, "TOPLEFT", 0, topOffset)
    window.sidebar:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT")
    window.sidebar:SetWidth(window.config.sidebar)
    SetBackgroundColor(window.sidebar, 0, 0, 0, 0.3)
  end

  -- Initialize titlebar buttons table
  window.titlebarButtons = {}

  -- Add titlebar buttons if provided
  if window.config.titlebarButtons then
    for _, buttonConfig in ipairs(window.config.titlebarButtons) do
      window:AddTitlebarButton(buttonConfig)
    end
  end

  local contentTopOffset = topOffset

  do
    local overlayLevel = window.body:GetFrameLevel() + 20
    if window.sidebar then
      overlayLevel = math.max(overlayLevel, window.sidebar:GetFrameLevel() + 20)
    end

    local progressOverlay = CreateFrame("Frame", "$parentProgressOverlay", window)
    window.progressOverlay = progressOverlay
    progressOverlay:SetPoint("TOPLEFT", window, "TOPLEFT", 0, contentTopOffset)
    progressOverlay:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 0)
    progressOverlay:SetFrameLevel(overlayLevel)
    progressOverlay:EnableMouse(true)
    progressOverlay:Hide()
    SetBackgroundColor(progressOverlay, window.config.windowColor.r, window.config.windowColor.g,
      window.config.windowColor.b, window.config.windowColor.a)

    progressOverlay.content = CreateFrame("Frame", "$parentContent", progressOverlay)
    progressOverlay.content:SetSize(320, 48)
    progressOverlay.content:SetPoint("CENTER")
    progressOverlay.content:SetFrameLevel(progressOverlay:GetFrameLevel() + 2)

    progressOverlay.text = progressOverlay.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    progressOverlay.text:SetPoint("TOP", progressOverlay.content, "TOP", 0, 0)
    progressOverlay.text:SetWidth(300)
    progressOverlay.text:SetWordWrap(true)
    progressOverlay.text:SetJustifyH("CENTER")

    progressOverlay.bar = CreateFrame("StatusBar", "$parentBar", progressOverlay.content)
    progressOverlay.bar:SetPoint("TOP", progressOverlay.text, "BOTTOM", 0, -12)
    progressOverlay.bar:SetSize(280, 14)
    progressOverlay.bar:SetFrameLevel(progressOverlay.content:GetFrameLevel() + 1)
    progressOverlay.bar:SetStatusBarTexture(LiqUI.Constants.layout.media.whiteSquare)
    progressOverlay.bar:SetMinMaxValues(0, 1)
    progressOverlay.bar:SetValue(0)
    local barFill = LiqUI.Constants.layout.colors.primary
    progressOverlay.bar:SetStatusBarColor(barFill.r, barFill.g, barFill.b, barFill.a)
    progressOverlay.bar.background = progressOverlay.bar:CreateTexture(nil, "BACKGROUND")
    progressOverlay.bar.background:SetAllPoints()
    progressOverlay.bar.background:SetTexture(LiqUI.Constants.layout.media.whiteSquare)
    progressOverlay.bar.background:SetVertexColor(0, 0, 0, 0.5)
  end

  ---@param text string|nil
  ---@param progress number|nil 0–1; omit to hide the bar (text only).
  function window:SetProgressOverlay(text, progress)
    window.progressOverlay.text:SetText(text or "")
    if progress ~= nil then
      window.progressOverlay.bar:Show()
      window.progressOverlay.bar:SetValue(math.max(0, math.min(1, progress)))
    else
      window.progressOverlay.bar:Hide()
    end
  end

  ---@param text string|nil
  ---@param progress number|nil
  function window:ShowProgressOverlay(text, progress)
    window:SetProgressOverlay(text, progress)
    window.progressOverlay:Show()
  end

  function window:HideProgressOverlay()
    window.progressOverlay:Hide()
  end

  ---@return boolean
  function window:IsProgressOverlayShown()
    return window.progressOverlay:IsShown()
  end

  window:Hide()
  table.insert(UISpecialFrames, window:GetName())
  self.windows[windowName] = window
  return window
end

---Get a window by name
---@param name string
---@return LiqUI_Window?
function Window:GetWindow(name)
  return self.windows[name]
end

---Centered placeholder text for module windows without a full layout yet.
---@param body LiqUI_WindowBody
---@return FontString
function Window:GetBodyPlaceholderText(body)
  if not body.placeholderText then
    body.placeholderText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    body.placeholderText:SetPoint("CENTER")
    body.placeholderText:SetWidth(body:GetWidth() - BODY_PLACEHOLDER_TEXT_INSET)
    body.placeholderText:SetWordWrap(true)
    body.placeholderText:SetJustifyH("CENTER")
  end
  return body.placeholderText
end

---Scale each window
---@param scale number
function Window:SetWindowScale(scale)
  TableForEach(self.windows, function(window)
    window:SetScale(scale)
  end)
end

---Set background color to each window
---@param color ColorTable
function Window:SetWindowBackgroundColor(color)
  TableForEach(self.windows, function(window)
    SetBackgroundColor(window, color.r, color.g, color.b, color.a)
  end)
end

---Get the maximum window width based on current screen width
---@return number
function Window:GetMaxWindowWidth()
  return GetScreenWidth() - LiqUI.Constants.layout.sizes.maxWindowWidthMargin
end

---Toggle a window by name (defaults to "Main")
---@param name string?
function Window:ToggleWindow(name)
  if name == nil or name == "" then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
  if window:IsVisible() then
    window:Hide()
  else
    window:Show()
  end
end
