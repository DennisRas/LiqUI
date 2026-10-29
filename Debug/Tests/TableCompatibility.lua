-- Run from the LiqUI root: lua Debug/Tests/TableCompatibility.lua
local methods = {}
local function frame()
  return setmetatable({ width = 300, height = 200, scripts = {}, points = {}, shown = true }, { __index = methods })
end
function methods:SetWidth(value) self.width = value end
function methods:SetHeight(value) self.height = value end
function methods:SetSize(w, h) self.width, self.height = w, h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:GetFrameLevel() return 1 end
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:HookScript() end
function methods:ClearAllPoints() self.points = {} end
function methods:SetPoint(...) self.points[#self.points + 1] = { ... } end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:CreateFontString() return frame() end
for _, method in ipairs({ "SetParent", "SetFrameLevel", "RegisterForClicks", "SetWordWrap", "SetFontObject", "SetJustifyH", "SetText", "SetClipsChildren" }) do
  methods[method] = function() end
end
CreateFrame = frame
format = string.format
local function merge(destination, source)
  for key, value in pairs(source) do
    if type(value) == "table" then
      destination[key] = destination[key] or {}
      merge(destination[key], value)
    else destination[key] = value end
  end
end
local library = { Utils = {}, Constants = { layout = { sizes = { header = 30, row = 20, padding = 4, column = 100 } } } }
LibStub = function() return library end
library.Utils.TableMergeOptions = merge
library.Utils.TableForEach = function(values, callback) for key, value in pairs(values) do callback(value, key) end end
library.Utils.SetBackgroundColor = function() end
library.Utils.SetHighlightColor = function() end
library.Utils.BindScrollBoxMouseWheel = function() end
library.Utils.CreateScrollArea = function(_, options)
  local scroll = { content = frame(), verticalScrollBar = frame(), horizontal = options.horizontal }
  if options.horizontal then scroll.horizontalScrollBox = frame() end
  function scroll:GetWheelScrollBox() return nil end
  function scroll:UpdateLayout(w, h) self.content:SetSize(w, h) end
  function scroll:SetParent() end
  function scroll:SetPoint() end
  function scroll:HookScript() end
  return scroll
end
function library:RegisterElement(_, create) self.create = create end
dofile("Elements/Table.lua")
local function eq(actual, expected, message)
  assert(actual == expected, message .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local legacy = library.create({ name = "Legacy", columns = { { id = "icon", width = 20.5 } }, header = { sticky = true } })
eq(legacy:GetColumnWidth("icon"), 20.5, "legacy narrow/fractional width")
eq(legacy.scrollArea.horizontal, false, "legacy horizontal scroll")
eq(legacy.headerRowFrame.cells[1].resizeHandle:IsShown(), false, "legacy handle")
legacy:SetData({ { "value" } })
eq(legacy:GetSize(), 20.5, "legacy content size")
local notifications = 0
local storage = { hiddenColumns = {} }
local columns = { { id = "a", width = 80 }, { id = "b", width = 60 } }
local tableFrame = library.create({ name = "Resizable", storage = storage, columns = columns,
  header = { sticky = true, resizable = true }, onLayoutChanged = function() notifications = notifications + 1 end })
tableFrame:SetColumnWidth("a", 123.4, true)
eq(storage.columnWidths.a, nil, "transient must not persist")
tableFrame:SetColumnWidth("a", 123.4)
eq(storage.columnWidths.a, 123, "commit persists rounded width")
tableFrame:SetColumnWidth("b", 5)
eq(tableFrame:GetColumnWidth("b"), 40, "resizable minimum")
tableFrame:SetColumnHidden("a", true)
tableFrame:SetColumns({ { id = "b", width = 60 }, { id = "a", width = 80 } })
tableFrame:SetColumnHidden("a", false)
eq(tableFrame:GetColumnWidth("a"), 123, "width follows id after reorder and hide")
tableFrame:SetData({ { data = { "span", "hidden" }, span = true, gapBefore = 3, gapAfter = 4, marker = "kept" } })
eq(tableFrame.data[1].marker, "kept", "host row fields")
eq(tableFrame.rowFrames[1].cells[1]:GetWidth(), 163, "span uses total width")
eq(tableFrame.rowFrames[1].cells[2]:IsShown(), false, "span hides other cells")
tableFrame:SetWidth(50)
tableFrame:Render()
local width, height = tableFrame:GetSize()
local contentWidth, contentHeight = tableFrame:GetContentSize()
eq(width, 163, "GetSize content width exceeds viewport")
eq(width, contentWidth, "size API width agreement")
eq(height, 57, "header and row gaps included")
eq(height, contentHeight, "size API height agreement")
eq(tableFrame.layoutSize.shownWidth, width, "legacy layoutSize width")
eq(tableFrame.layoutSize.shownHeight, height, "legacy layoutSize height")
tableFrame:ResetColumnWidth("a")
eq(tableFrame:GetColumnWidth("a"), 80, "reset restores default")
eq(storage.columnWidths.a, nil, "reset clears saved width")
assert(notifications >= 4, "layout callback missing")
print("PASS: legacy sizing, resize persistence, dynamic columns, row spans and size APIs")
