local Utils = LiqUI.Utils

---Merge defaults with options; ensure parent (default UIParent).
function Utils.PrepareOptions(defaults, options)
  local opts = Utils.MergeDeep(defaults or { parent = UIParent }, options or {})
  opts.parent = opts.parent or UIParent
  return opts
end

---Create a font string with theme text color. anchor: { point, relativeTo, relativePoint, x, y }.
function Utils.CreateLabel(parent, text, anchor)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  if anchor then
    fs:SetPoint(anchor.point or "LEFT", anchor.relativeTo or parent, anchor.relativePoint or "LEFT", anchor.x or 0,
      anchor.y or 0)
  end
  fs:SetText(text or "")
  fs:SetTextColor(LiqUI.Config.text.defaultColor:GetRGBA())
  return fs
end

---Find a table item by callback
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): boolean
---@return T|nil, any
function Utils.TableFind(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for i, v in pairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

---Find a table item by key and value
---@generic T
---@param tbl table<any, T>
---@param key string
---@param val any
---@return T|nil, any
function Utils.TableGet(tbl, key, val)
  return Utils.TableFind(tbl, function(elm, _)
    return elm[key] and elm[key] == val
  end)
end

---Create a new table containing all elements that pass truth test
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): boolean
---@return T[]
function Utils.TableFilter(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  for i, v in pairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

---Count table items
---@param tbl table<any, any>
---@return number
function Utils.TableCount(tbl)
  assert(type(tbl) == "table", "Must be a table!")
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

---Deep merge overlay into base. Nested tables are merged recursively; overlay values override base. Returns new table.
---@param base table
---@param overlay table
---@return table
function Utils.MergeDeep(base, overlay)
  local result = Utils.TableCopy(base)
  for k, v in pairs(overlay) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = Utils.MergeDeep(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

---Deep copy a table
---@generic T
---@param tbl table<any, T>
---@param cache table?
---@return table<any, any>
function Utils.TableCopy(tbl, cache)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  cache = cache or {}
  cache[tbl] = t
  Utils.TableForEach(tbl, function(v, k)
    if type(v) == "table" then
      t[k] = cache[v] or Utils.TableCopy(v, cache)
    else
      t[k] = v
    end
  end)
  return t
end

---Map each item in a table
---@generic T, V
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): V, any?
---@return table<any, V>
function Utils.TableMap(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  Utils.TableForEach(tbl, function(v, k)
    local newv, newk = callback(v, k)
    t[newk and newk or k] = newv
  end)
  return t
end

---Run a callback on each table item
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any)
---@return table<any, T>
function Utils.TableForEach(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

---Iterate table keys sorted by optional order field (AceConfig-style). Yields key.
---@param tbl table
---@return fun(): string?, any
function Utils.SortedPairs(tbl)
  local keys = {}
  for k in pairs(tbl) do
    keys[#keys + 1] = k
  end
  local orderVal = function(k)
    local v = tbl[k]
    if type(v) == "table" and type(v.order) == "number" then
      return v.order
    end
    return 100
  end
  table.sort(keys, function(a, b) return orderVal(a) < orderVal(b) end)
  local i = 0
  return function()
    i = i + 1
    return keys[i]
  end
end

---Highlight mixin: overlay for hover/selection. Use Mixin(frame, LiqUI.Mixins.Highlight).
---Call SetVertexColor(r,g,b,a) then ShowHighlight() / HideHighlight(); does not override frame Show/Hide.
---@class LiqUI_HighlightMixin
LiqUI.Mixins = LiqUI.Mixins or {}
LiqUI.Mixins.Highlight = {}
local Highlight = LiqUI.Mixins.Highlight

function Highlight:SetHighlightColor(r, g, b, a)
  if not self.Highlight then
    self.Highlight = self:CreateTexture("Highlight", "OVERLAY")
    self.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    self.Highlight:SetAllPoints()
    self.Highlight:Hide()
  end
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 0.05
  self.Highlight:SetVertexColor(r, g, b, a)
end

function Highlight:ShowHighlight(r, g, b, a)
  if not self.Highlight then
    self:SetHighlightColor(r, g, b, a)
  elseif r then
    self:SetHighlightColor(r, g, b, a)
  end
  self.Highlight:Show()
end

function Highlight:HideHighlight()
  if not self.Highlight then
    return
  end
  self.Highlight:Hide()
end

---Create a scrollable content area using Blizzard WowScrollBox + CreateScrollBoxLinearView + MinimalScrollBar.
---Parent content to .scrollChild and set its height; after content size changes call :FullUpdate(true).
---@param parent Frame
---@param name string?
---@param options { barWidth?: number }?
---@return Frame scrollBox WowScrollBox with .scrollChild, :FullUpdate(), :ScrollToBegin()
function Utils.CreateScrollBox(parent, name, options)
  options = options or {}
  local barWidth = options.barWidth or 12

  if not ScrollUtil or not CreateScrollBoxLinearView then
    error(
    "LiqUI.CreateScrollBox requires Blizzard_SharedXML (ScrollUtil, CreateScrollBoxLinearView). Ensure UI is loaded.")
  end

  local scrollBox = CreateFrame("Frame", name, parent, "WowScrollBox")
  local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 0, 0)
  scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 0, 0)
  scrollBar:SetWidth(barWidth)

  local scrollArea = CreateFrame("Frame", nil, scrollBox)
  scrollArea.scrollable = true
  scrollArea:SetSize(1, 1)

  local inset = 0
  local view = CreateScrollBoxLinearView(inset, inset, inset, inset, 0)
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)
  scrollBar:SetHideIfUnscrollable(true)

  scrollBox.scrollChild = scrollArea
  scrollBox.ScrollBar = scrollBar

  scrollBox:SetScript("OnSizeChanged", function()
    local width = scrollBox:GetWidth()
    if width and width > 0 then
      scrollArea:SetWidth(width)
    end
  end)

  return scrollBox
end
