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

---@return LiqUI_TableData
local function galleryData()
  ---@type LiqUI_TableData
  local data = {}
  for index = 1, 40 do
    local flag = index % 3 == 0 and "Yes" or "No"
    if index % 5 == 0 then
      ---@type LiqUI_TableDataRowExtended
      local row = {
        data = {
          format("Row %d", index),
          index * 10,
          {
            data = flag,
            onEnter = function(cellFrame, rowFrame, rowIndex, columnIndex, columnId, rowData, cellData)
              GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
              GameTooltip:SetText(format("Extended cell on row %d", index), 1, 1, 1)
              GameTooltip:Show()
            end,
            onLeave = function(cellFrame, rowFrame, rowIndex, columnIndex, columnId, rowData, cellData)
              GameTooltip:Hide()
            end,
          },
        },
        backgroundColor = { r = 0.2, g = 0.4, b = 0.6, a = 0.25 },
      }
      data[index] = row
    else
      ---@type LiqUI_TableDataRow
      data[index] = { format("Row %d", index), index * 10, flag }
    end
  end
  return data
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

  ---@type LiqUI_TableConfig
  local tableConfig = {
    name = "Gallery",
    columns = {
      {
        id = "name",
        headerText = "Name",
        width = 180,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            return rowA.data[1].data < rowB.data[1].data
          end,
        },
      },
      {
        id = "value",
        headerText = "Value",
        width = 80,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            return rowA.data[2].data < rowB.data[2].data
          end,
        },
      },
      {
        id = "flag",
        headerText = "Flag",
        width = 60,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            if rowA.data[3].data ~= rowB.data[3].data then
              return rowA.data[3].data == "Yes"
            end
            return rowA.data[1].data < rowB.data[1].data
          end,
        },
      },
    },
    header = {
      enabled = true,
      sticky = true,
    },
    sorting = {
      enabled = true,
      defaultOrder = "asc",
      defaultCompare = function(rowA, rowB)
        return rowA.data[1].data < rowB.data[1].data
      end,
    },
  }

  galleryTable = liqui.Table:New(tableConfig)
  galleryTable:SetParent(galleryWindow.body)
  galleryTable:SetAllPoints(galleryWindow.body)
  galleryTable:SetData(galleryData())
end

SLASH_LIQUI1 = "/liqui"
SlashCmdList.LIQUI = function()
  ensureGallery()
  galleryWindow:Toggle()
end
