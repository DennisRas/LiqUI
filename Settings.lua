local C = LiqUI.Config
local s = C.settings
local sb = s.sidebar
local fm = s.form
local BACKDROP = C.shared.backdropTexture

LiqUIDB = LiqUIDB or {}

local registrations = {}

local Settings = {}
LiqUI.Settings = Settings

---Register an addon's options with the Settings UI.
---Each addon has at least one page (e.g. General).
---AceConfig-compatible: { type = "group", args = { general = { type = "group", name = "General", args = {...} } } }
---@param id string Addon identifier (e.g. "LiqMe")
---@param options table|fun():table AceConfig format or { General = opts }
---@param label string? Display name in sidebar (defaults to id)
---@param icon string? Texture path for addon icon (or nil to try TOC X-Icon / X-AddonIcon)
function Settings:Register(id, options, label, icon)
  registrations[id] = {
    options = options,
    label = label or id,
    icon = icon,
  }
end

---Extract pages from options. Supports:
---1. AceConfig: { type = "group", args = { general = { type = "group", name = "General", args = {...} } } }
---2. Shorthand: { General = { type = "group", args = {...} } }
---3. Single group: { type = "group", args = {...} } -> wrapped as General
local function NormalizePages(reg)
  local raw = type(reg.options) == "function" and reg.options() or reg.options
  if not raw then return nil end
  -- AceConfig: root has type="group" and args with subgroup entries
  if raw.type == "group" and raw.args then
    local pages = {}
    for key, val in pairs(raw.args) do
      if type(val) == "table" and (val.type == "group" or val.args) then
        pages[key] = val
      end
    end
    if next(pages) then
      return pages
    end
    return { general = raw }
  end
  -- Shorthand { General = {...} } or single group
  if raw.args then
    return { General = raw }
  end
  return raw
end

---Unregister an addon's options.
---@param id string
function Settings:Unregister(id)
  registrations[id] = nil
end

local function GetOptionValue(opt, path, handler)
  local get = opt.get
  if not get then return nil end
  local info = { arg = opt.arg }
  if type(get) == "function" then
    return get(info)
  end
  if type(get) == "string" and handler and handler[get] then
    return handler[get](handler, info)
  end
  return nil
end

local function SetOptionValue(opt, path, handler, value)
  local set = opt.set
  if not set then return end
  local info = { arg = opt.arg }
  if type(set) == "function" then
    set(info, value)
  elseif type(set) == "string" and handler and handler[set] then
    handler[set](handler, info, value)
  end
end

local function RefreshFormValues(formFrame)
  for _, row in ipairs(formFrame.formRows or {}) do
    if row.widget and row.widget.SetValue and row.getValue then
      local ok, a, b, c, d = pcall(row.getValue)
      if ok and a ~= nil then
        row.widget:SetValue(a, b, c, d)
      end
    end
  end
end

local function BuildForm(parent, options, handler)
  local opts = options
  if opts.type == "group" then
    opts = opts
  else
    opts = { type = "group", args = opts.args or opts }
  end

  parent.formRows = {}
  local args = opts.args or {}
  local y = -fm.padding
  local contentWidth = math.max(200, (parent:GetWidth() or 400) - 40)

  -- Decide which control gets the line under it: if both header and description exist, under description; else under first of either
  local firstHeaderKey, firstDescKey
  for key in LiqUI.Utils.SortedPairs(args) do
    local t = args[key] and (args[key].type or "input")
    if t == "header" and not firstHeaderKey then firstHeaderKey = key end
    if t == "description" and not firstDescKey then firstDescKey = key end
  end
  local lineUnderKey = (firstHeaderKey and firstDescKey) and firstDescKey or firstHeaderKey or firstDescKey

  for key in LiqUI.Utils.SortedPairs(args) do
    local opt = args[key]
    if opt then
      local optType = opt.type or "input"
      local name = (type(opt.name) == "string") and opt.name or key
      local desc = (type(opt.desc) == "string") and opt.desc or nil
      local control

      if optType == "input" then
        local val = GetOptionValue(opt, { key }, opts.handler or handler)
        local widget = LiqUI.Widgets.CreateEditBox(parent, {
          value = tostring(val or ""),
          width = fm.widgetWidthEdit,
          OnValueChanged = function(v)
            SetOptionValue(opt, { key }, opts.handler or handler, v)
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
          widgetWidth = fm.widgetWidthEdit,
        })
        table.insert(parent.formRows,
          { widget = widget, getValue = function() return GetOptionValue(opt, { key }, opts.handler or handler) end })
      elseif optType == "toggle" then
        local val = GetOptionValue(opt, { key }, opts.handler or handler)
        local widget = LiqUI.Widgets.CreateCheckBox(parent, {
          checked = val,
          OnValueChanged = function(v)
            SetOptionValue(opt, { key }, opts.handler or handler, v)
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
          widgetWidth = fm.widgetWidthCheck,
        })
        table.insert(parent.formRows,
          { widget = widget, getValue = function() return GetOptionValue(opt, { key }, opts.handler or handler) end })
      elseif optType == "execute" then
        local func = opt.func
        if type(func) == "function" then
          local widget = LiqUI.Widgets.CreateButton(parent, {
            label = name,
            width = fm.widgetWidthButton,
            OnClick = function()
              func({ arg = opt.arg })
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
            widgetWidth = fm.widgetWidthButton,
          })
        end
      elseif optType == "select" then
        local values = opt.values
        if type(values) == "function" then values = values() end
        if type(values) == "table" then
          local val = GetOptionValue(opt, { key }, opts.handler or handler)
          local widget = LiqUI.Widgets.CreateDropdown(parent, {
            values = values,
            value = val,
            width = fm.widgetWidthDropdown,
            OnValueChanged = function(v)
              SetOptionValue(opt, { key }, opts.handler or handler, v)
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
            widgetWidth = fm.widgetWidthDropdown,
          })
          table.insert(parent.formRows,
            { widget = widget, getValue = function() return GetOptionValue(opt, { key }, opts.handler or handler) end })
        end
      elseif optType == "multiselect" then
        local values = opt.values
        if type(values) == "function" then values = values() end
        if type(values) == "table" then
          local widget = LiqUI.Widgets.CreateMultiSelect(parent, {
            values = values,
            width = fm.widgetWidthDropdown,
            get = function(k)
              local info = { arg = opt.arg }
              if opt.get then
                if type(opt.get) == "function" then return opt.get(info, k) end
                if opts.handler and opts.handler[opt.get] then return opts.handler[opt.get](opts.handler, info, k) end
              end
              return false
            end,
            set = function(k, v)
              local info = { arg = opt.arg }
              if opt.set then
                if type(opt.set) == "function" then opt.set(info, k, v) end
                if opts.handler and opts.handler[opt.set] then opts.handler[opt.set](opts.handler, info, k, v) end
              end
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
            widgetWidth = fm.widgetWidthDropdown,
          })
        end
      elseif optType == "color" then
        local hasAlpha = opt.hasAlpha
        local function getColor()
          if not opt.get then return 1, 1, 1, 1 end
          local info = { arg = opt.arg }
          if type(opt.get) == "function" then return opt.get(info) end
          if opts.handler and opt.get and opts.handler[opt.get] then return opts.handler[opt.get](opts.handler, info) end
          return 1, 1, 1, 1
        end
        local gr, gg, gb, ga = getColor()
        if ga == nil then ga = 1 end
        local widget = LiqUI.Widgets.CreateColorPicker(parent, {
          r = gr,
          g = gg,
          b = gb,
          a = ga,
          hasAlpha = hasAlpha,
          OnValueChanged = function(nr, ng, nb, na)
            local info = { arg = opt.arg }
            if opt.set then
              if type(opt.set) == "function" then opt.set(info, nr, ng, nb, na) end
              if opts.handler and opt.set and opts.handler[opt.set] then
                opts.handler[opt.set](opts.handler, info, nr, ng,
                  nb, na)
              end
            end
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
          widgetWidth = fm.widgetWidthColor,
        })
        table.insert(parent.formRows, { widget = widget, getValue = getColor })
      elseif optType == "header" then
        control = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        control:SetText(name)
        control:SetWordWrap(true)
        control:SetWidth(contentWidth - fm.padding * 2)
        control:SetHeight(20)
        control:SetTextColor(1, 1, 1)
        control:SetJustifyH("LEFT")
        control:SetFontObject("GameFontNormalLarge")
      elseif optType == "description" then
        control = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        control:SetText(name)
        control:SetWordWrap(true)
        control:SetWidth(contentWidth - fm.padding * 2)
        control:SetHeight(20)
        control:SetTextColor(1, 1, 1)
        control:SetJustifyH("LEFT")
      end

      if control then
        control:SetPoint("TOPLEFT", parent, "TOPLEFT", fm.padding, y)
        control:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -fm.padding, y)
        local h = control:GetHeight() or 24
        local spacingAfter = fm.rowSpacingDefault
        if type(opt.spacingAfter) == "number" then
          spacingAfter = opt.spacingAfter
        elseif optType == "header" then
          spacingAfter = fm.rowSpacingAfterHeader
        elseif optType == "description" then
          spacingAfter = fm.rowSpacingAfterDescription
        end
        y = y - h - spacingAfter
        -- Line below header or description: under description if page has both, else under the first of either
        if lineUnderKey and key == lineUnderKey and (optType == "header" or optType == "description") then
          local line = parent:CreateTexture(nil, "OVERLAY")
          line:SetColorTexture(C.form.headerLineColor:GetRGBA())
          line:SetHeight(fm.headerLineHeight)
          line:SetPoint("TOPLEFT", parent, "TOPLEFT", fm.padding, y)
          line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -fm.padding, y)
          y = y - fm.headerLineHeight - fm.headerLineGap
        end
      end
    end
  end

  parent:SetHeight(math.max(1, -y + fm.padding))
end

local settingsWindow = nil

--- Pool helpers: acquire returns a frame (from pool or new), release returns it to the pool.
local function acquireFromPool(pool, createFn)
  if #pool > 0 then
    return table.remove(pool)
  end
  return createFn()
end

local function releaseToPool(pool, frame, resetFn)
  if resetFn then resetFn(frame) end
  frame:SetParent(nil)
  frame:Hide()
  table.insert(pool, frame)
end

local function BuildTree()
  local addons = {}
  for id, reg in pairs(registrations) do
    local pages = NormalizePages(reg)
    if pages then
      local raw = type(reg.options) == "function" and reg.options() or reg.options
      local args = raw and raw.args or pages
      local pageList = {}
      for pageId in LiqUI.Utils.SortedPairs(args) do
        local pageOpts = pages[pageId]
        if pageOpts then
          local label = pageId
          if type(pageOpts) == "table" and type(pageOpts.name) == "string" then
            label = pageOpts.name
          end
          local order = (type(pageOpts) == "table" and type(pageOpts.order) == "number") and pageOpts.order or 100
          table.insert(pageList, { pageId = pageId, pageLabel = label, order = order })
        end
      end
      table.sort(pageList, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.pageLabel < b.pageLabel
      end)
      local icon = reg.icon
      if not icon and C_AddOns and C_AddOns.GetAddOnMetadata then
        icon = C_AddOns.GetAddOnMetadata(id, "X-Icon") or C_AddOns.GetAddOnMetadata(id, "X-AddonIcon")
      end
      table.insert(addons, {
        addonId = id,
        addonLabel = reg.label or id,
        addonIcon = icon,
        expanded = true,
        pages = pageList,
      })
    end
  end
  table.sort(addons, function(a, b) return a.addonLabel < b.addonLabel end)
  return addons
end

local function UpdateScrollBarVisibility(scrollFrame)
  local range = scrollFrame:GetVerticalScrollRange()
  local bar = scrollFrame.ScrollBar or (scrollFrame:GetName() and _G[scrollFrame:GetName() .. "ScrollBar"])
  if bar then
    if range and range > 0 then bar:Show() else bar:Hide() end
  end
end

---Open the Settings window. Creates it if needed.
function Settings:Open()
  if not settingsWindow then
    settingsWindow = LiqUI.Window:New({
      name = "LiqUISettings",
      title = "Settings",
      point = { "CENTER", 0, 0 },
    })
    settingsWindow:SetBodySize(s.windowWidth, s.windowHeight)

    local body = settingsWindow.body
    local tree = BuildTree()
    local selectedAddonId = nil
    local selectedPageId = nil
    local sidebarRows = {}
    local formFrame = nil
    local formCache = {} -- formCache[addonId][pageId] = formFrame
    local sidebarAddonPool = {}
    local sidebarPagePool = {}

    local function createAddonRowButton()
      local addonBtn = CreateFrame("Button", nil, nil, "BackdropTemplate")
      addonBtn:SetHeight(sb.itemHeight)
      addonBtn:SetBackdrop({ bgFile = BACKDROP, tile = true, tileSize = 8 })
      addonBtn:SetBackdropColor(C.sidebar.rowBackgroundColor:GetRGBA())
      local iconLeft
      local iconTex = addonBtn:CreateTexture(nil, "OVERLAY")
      iconTex:SetPoint("LEFT", addonBtn, "LEFT", sb.padding, 0)
      iconTex:SetSize(sb.iconSize, sb.iconSize)
      addonBtn.iconTex = iconTex
      local iconPlaceholder = addonBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      iconPlaceholder:SetPoint("LEFT", addonBtn, "LEFT", sb.padding, 0)
      iconPlaceholder:SetSize(sb.iconSize, sb.iconSize)
      iconPlaceholder:SetJustifyH("CENTER")
      iconPlaceholder:SetJustifyV("MIDDLE")
      iconPlaceholder:SetText("?")
      iconPlaceholder:SetTextColor(C.text.placeholderColor:GetRGBA())
      addonBtn.iconPlaceholder = iconPlaceholder
      local label = addonBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftOrange")
      label:SetPoint("LEFT", iconTex, "RIGHT", 4, 0)
      label:SetPoint("RIGHT", addonBtn, "RIGHT", -sb.padding - sb.arrowWidth - 4, 0)
      label:SetJustifyH("LEFT")
      addonBtn.label = label
      local arrowTex = addonBtn:CreateTexture(nil, "OVERLAY")
      arrowTex:SetPoint("RIGHT", addonBtn, "RIGHT", -sb.padding, 0)
      arrowTex:SetSize(sb.arrowWidth, sb.arrowHeight)
      arrowTex:SetScale(0.8)
      addonBtn.arrowTex = arrowTex
      return addonBtn
    end

    local function createPageRowButton()
      local pageBtn = CreateFrame("Button", nil, nil, "BackdropTemplate")
      pageBtn:SetHeight(sb.itemHeight)
      pageBtn:SetBackdrop({ bgFile = BACKDROP, tile = true, tileSize = 8 })
      local pageLabel = pageBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      pageLabel:SetPoint("LEFT", pageBtn, "LEFT", sb.pageIndent + sb.padding, 0)
      pageLabel:SetPoint("RIGHT", pageBtn, "RIGHT", -sb.padding, 0)
      pageLabel:SetJustifyH("LEFT")
      pageBtn.label = pageLabel
      return pageBtn
    end

    local function releaseSidebarAddon(btn)
      btn:SetScript("OnClick", nil)
      btn:SetScript("OnEnter", nil)
      btn:SetScript("OnLeave", nil)
      btn.addonRef = nil
      releaseToPool(sidebarAddonPool, btn, nil)
    end

    local function releaseSidebarPage(btn)
      btn:SetScript("OnClick", nil)
      btn:SetScript("OnEnter", nil)
      btn:SetScript("OnLeave", nil)
      releaseToPool(sidebarPagePool, btn, nil)
    end

    local sidebar = CreateFrame("Frame", "$parentSidebar", body, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
    sidebar:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(sb.width)
    sidebar:SetBackdrop({ bgFile = BACKDROP, tile = true, tileSize = 8 })
    sidebar:SetBackdropColor(C.sidebar.backgroundColor:GetRGBA())

    local content = CreateFrame("Frame", "$parentContent", body)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", 0, 0)
    content:SetFrameLevel(sidebar:GetFrameLevel() + 1)

    local scrollFrame = CreateFrame("ScrollFrame", "$parentScroll", content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", fm.padding, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -24, 0)
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame:SetScript("OnSizeChanged", function()
      local w = scrollFrame:GetWidth()
      if w and w > 0 then
        scrollChild:SetWidth(w)
      end
    end)

    local function ShowPage(addonId, pageId)
      selectedAddonId = addonId
      selectedPageId = pageId
      local reg = registrations[addonId]
      if not reg then return end
      local pages = NormalizePages(reg)
      local opts = pages and pages[pageId]
      if not opts then return end
      if formFrame then
        formFrame:SetParent(nil)
        formFrame:Hide()
      end
      formCache[addonId] = formCache[addonId] or {}
      local cached = formCache[addonId][pageId]
      if cached then
        formFrame = cached
        formFrame:SetParent(scrollChild)
        formFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT")
        formFrame:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT")
        formFrame:Show()
        RefreshFormValues(formFrame)
      else
        local scrollW = math.max(1, scrollFrame:GetWidth() or 400)
        scrollChild:SetSize(scrollW, 1)
        formFrame = CreateFrame("Frame", nil, scrollChild)
        formFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT")
        formFrame:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT")
        BuildForm(formFrame, opts)
        formCache[addonId][pageId] = formFrame
      end
      scrollChild:SetHeight(formFrame:GetHeight())
      UpdateScrollBarVisibility(scrollFrame)
    end

    local function RefreshSidebar()
      for _, r in ipairs(sidebarRows) do
        if r.btn then
          if r.isAddon then
            releaseSidebarAddon(r.btn)
          else
            releaseSidebarPage(r.btn)
          end
        end
      end
      sidebarRows = {}

      local y = 0
      for _, addon in ipairs(tree) do
        local expanded = addon.expanded ~= false
        local addonBtn = acquireFromPool(sidebarAddonPool, createAddonRowButton)
        addonBtn:SetParent(sidebar)
        addonBtn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, y)
        addonBtn:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, y)
        addonBtn:SetBackdropColor(C.sidebar.rowBackgroundColor:GetRGBA())
        if addon.addonIcon and addon.addonIcon ~= "" then
          addonBtn.iconTex:SetTexture(addon.addonIcon)
          addonBtn.iconTex:Show()
          addonBtn.iconPlaceholder:Hide()
          addonBtn.label:SetPoint("LEFT", addonBtn.iconTex, "RIGHT", 4, 0)
        else
          addonBtn.iconTex:SetTexture(nil)
          addonBtn.iconTex:Hide()
          addonBtn.iconPlaceholder:Show()
          addonBtn.label:SetPoint("LEFT", addonBtn.iconPlaceholder, "RIGHT", 4, 0)
        end
        addonBtn.label:SetText(addon.addonLabel or addon.addonId)
        addonBtn.arrowTex:SetRotation(expanded and sb.arrowRotationDown or sb.arrowRotationRight)
        addonBtn.arrowTex:SetAtlas(expanded and sb.arrowAtlas or sb.arrowAtlasDisabled)
        addonBtn.addonRef = addon
        addonBtn:SetScript("OnClick", function()
          if not addon.expanded then
            for _, a in ipairs(tree) do
              a.expanded = (a == addon)
            end
            if addon.pages and #addon.pages > 0 then
              ShowPage(addon.addonId, addon.pages[1].pageId)
            end
          else
            addon.expanded = false
          end
          RefreshSidebar()
        end)
        addonBtn:SetScript("OnEnter", function()
          addonBtn:SetBackdropColor(C.sidebar.rowBackgroundColorHover:GetRGBA())
          addonBtn.arrowTex:SetRotation(addon.expanded and sb.arrowRotationDown or sb.arrowRotationRight)
          addonBtn.arrowTex:SetAtlas(sb.arrowAtlasHover)
        end)
        addonBtn:SetScript("OnLeave", function()
          addonBtn:SetBackdropColor(C.sidebar.rowBackgroundColor:GetRGBA())
          local exp = addonBtn.addonRef and addonBtn.addonRef.expanded ~= false
          addonBtn.arrowTex:SetRotation(exp and sb.arrowRotationDown or sb.arrowRotationRight)
          addonBtn.arrowTex:SetAtlas(exp and sb.arrowAtlas or sb.arrowAtlasDisabled)
        end)
        addonBtn:Show()
        sidebarRows[#sidebarRows + 1] = { btn = addonBtn, isAddon = true }
        y = y - sb.itemHeight

        if expanded and addon.pages and #addon.pages > 0 then
          for _, page in ipairs(addon.pages) do
            local pageBtn = acquireFromPool(sidebarPagePool, createPageRowButton)
            pageBtn:SetParent(sidebar)
            pageBtn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, y)
            pageBtn:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, y)
            local isSelected = (selectedAddonId == addon.addonId and selectedPageId == page.pageId)
            local sc = isSelected and C.sidebar.pageSelectedColor or C.sidebar.rowBackgroundColor
            pageBtn:SetBackdropColor(sc:GetRGBA())
            pageBtn.label:SetText(page.pageLabel or page.pageId)
            pageBtn.label:SetTextColor(C.text.defaultColor:GetRGBA())
            pageBtn:SetScript("OnClick", function()
              ShowPage(addon.addonId, page.pageId)
              RefreshSidebar()
            end)
            pageBtn:SetScript("OnEnter", function()
              if selectedAddonId ~= addon.addonId or selectedPageId ~= page.pageId then
                pageBtn:SetBackdropColor(C.sidebar.pageBackgroundColorHover:GetRGBA())
              end
            end)
            pageBtn:SetScript("OnLeave", function()
              if selectedAddonId ~= addon.addonId or selectedPageId ~= page.pageId then
                pageBtn:SetBackdropColor(C.sidebar.rowBackgroundColor:GetRGBA())
              end
            end)
            pageBtn:Show()
            sidebarRows[#sidebarRows + 1] = { btn = pageBtn, isAddon = false }
            y = y - sb.itemHeight
          end
        end
      end
    end

    if #tree > 0 then
      for i, a in ipairs(tree) do
        a.expanded = (i == 1)
      end
      if tree[1].pages and #tree[1].pages > 0 then
        ShowPage(tree[1].addonId, tree[1].pages[1].pageId)
      end
    end
    RefreshSidebar()
  end

  settingsWindow:Show()
end

---Toggle the Settings window.
function Settings:Toggle()
  if settingsWindow and settingsWindow:IsVisible() then
    settingsWindow:Hide()
  else
    self:Open()
  end
end

-- LiqUI's own settings (auto open on load)
Settings:Register("LiqUI", {
  type = "group",
  args = {
    general = {
      type = "group",
      name = "General",
      args = {
        autoOpenSettings = {
          type = "toggle",
          name = "Open Settings on load",
          desc = "Automatically open the Settings window when you log in",
          get = function() return LiqUIDB.autoOpenSettings end,
          set = function(_, v) LiqUIDB.autoOpenSettings = v end,
          order = 1,
        },
      },
    },
  },
}, "LiqUI")

-- Auto-open on load when option is set
local autoOpenFrame = CreateFrame("Frame")
autoOpenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
autoOpenFrame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    autoOpenFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if LiqUIDB.autoOpenSettings then
      Settings:Open()
    end
  end
end)
