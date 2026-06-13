local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

LiqUIDB = LiqUIDB or {}
LiqUIDB.liqui = LiqUIDB.liqui or {}

local liqui = LiqUI:New({ name = "LiqUI", db = LiqUIDB.liqui })

local galleryWindow
local galleryTable
local progressVisible = false

local function buildSampleDataRows()
  ---@type LiqUI_TableDataRow[]
  local rows = {}
  for index = 1, 40 do
    ---@type LiqUI_TableDataRow
    local row = { data = { index = index } }
    if index % 5 == 0 then
      row.backgroundColor = { r = 0.2, g = 0.4, b = 0.6, a = 0.25 }
    end
    table.insert(rows, row)
  end
  return rows
end

local function ensureGallery()
  if galleryWindow then
    return
  end

  ---@type LiqUI_WindowOptions
  local windowOptions = {
    name = "Gallery",
    title = "LiqUI Gallery",
    width = 520,
    height = 400,
    titlebarButtons = {
      {
        name = "Progress",
        icon = "Interface/ICONS/INV_Misc_Gear_01",
        tooltipTitle = "Toggle progress overlay",
        tooltipDescription = "Demonstrates ShowProgressOverlay / HideProgressOverlay.",
        onClick = function()
          if not galleryWindow then
            return
          end
          progressVisible = not progressVisible
          if progressVisible then
            galleryWindow:ShowProgressOverlay("Loading sample data...", 0.65)
          else
            galleryWindow:HideProgressOverlay()
          end
        end,
      },
    },
  }

  galleryWindow = liqui.Window:New(windowOptions)

  ---@type LiqUI_TableDataColumn[]
  local columns = {
    {
      id = "name",
      headerText = "Name",
      width = 180,
      render = function(data)
        return { text = format("Row %d", data.index) }
      end,
      sorting = {
        enabled = true,
        compare = function(a, b)
          local aText = a.columns[1] and a.columns[1].text or ""
          local bText = b.columns[1] and b.columns[1].text or ""
          return aText < bText
        end
      }
    },
    {
      id = "value",
      headerText = "Value",
      width = 80,
      render = function(data)
        return { text = format("%d", data.index * 10) }
      end,
      sorting = {
        enabled = true,
        compare = function(a, b)
          local aNum = tonumber(a.columns[2] and a.columns[2].text) or 0
          local bNum = tonumber(b.columns[2] and b.columns[2].text) or 0
          return aNum < bNum
        end
      }
    },
    {
      id = "flag",
      headerText = "Flag",
      width = 60,
      render = function(data)
        return { text = data.index % 3 == 0 and "Yes" or "No" }
      end,
      sorting = {
        enabled = true,
        compare = function(a, b)
          local aText = a.columns[3] and a.columns[3].text or ""
          local bText = b.columns[3] and b.columns[3].text or ""
          return aText < bText
        end
      }
    },
  }

  ---@type LiqUI_TableConfig
  local tableConfig = {
    name = "Gallery",
    header = {
      enabled = true,
      sticky = true,
    },
    sorting = {
      enabled = true,
      defaultOrder = "asc",
      defaultCompare = function(a, b)
        local aText = a.columns[1] and a.columns[1].text or ""
        local bText = b.columns[1] and b.columns[1].text or ""
        return aText < bText
      end,
    },
    data = LiqUI.Table.BuildData(columns, buildSampleDataRows()),
  }

  galleryTable = liqui.Table:New(tableConfig)
  galleryTable:SetParent(galleryWindow.body)
  galleryTable:SetAllPoints(galleryWindow.body)
  galleryTable:RenderTable()
end

SLASH_LIQUI1 = "/liqui"
SlashCmdList.LIQUI = function()
  ensureGallery()
  galleryWindow:Toggle()
end
