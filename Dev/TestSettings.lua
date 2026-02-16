LiqUIDB = LiqUIDB or {}
LiqUIDB.dev = LiqUIDB.dev or {}

local function devGet(key) return LiqUIDB.dev and LiqUIDB.dev[key] end
local function devSet(key, val)
  LiqUIDB.dev = LiqUIDB.dev or {}
  LiqUIDB.dev[key] = val
end

local function printMsg(...) print("|cff67AFD6LiqUI:|r", ...) end

local options = {
  type = "group",
  args = {
    appearance = {
      type = "group",
      name = "Appearance",
      order = 1,
      args = {
        header = { type = "header", name = "Appearance", order = 0 },
        desc = { type = "description", name = "Placeholder options for layout testing. Values are stored but not used.", order = 1 },
        showMinimapIcon = {
          type = "toggle",
          name = "Show minimap icon",
          desc = "Display the addon icon on the minimap (dev placeholder).",
          get = function() return devGet("showMinimapIcon") end,
          set = function(_, v) devSet("showMinimapIcon", v) end,
          order = 10,
        },
        windowScale = {
          type = "input",
          name = "Window scale",
          desc = "Scale factor for the main window (e.g. 100 for 100%%).",
          get = function() return tostring(devGet("windowScale") or "100") end,
          set = function(_, v) devSet("windowScale", v) end,
          order = 20,
        },
        useCompactMode = {
          type = "toggle",
          name = "Compact mode",
          desc = "Use a more compact layout for the interface.",
          get = function() return devGet("useCompactMode") end,
          set = function(_, v) devSet("useCompactMode", v) end,
          order = 30,
        },
        theme = {
          type = "select",
          name = "Theme",
          desc = "UI theme (dev placeholder).",
          values = { light = "Light", dark = "Dark", system = "System" },
          get = function() return devGet("theme") or "dark" end,
          set = function(_, v) devSet("theme", v) end,
          order = 40,
        },
        accentColor = {
          type = "color",
          name = "Accent color",
          desc = "Primary accent color (dev placeholder).",
          hasAlpha = false,
          get = function()
            local c = LiqUIDB.dev and LiqUIDB.dev.accentColor
            if c then return c.r, c.g, c.b, 1 end
            return 0.3, 0.5, 0.8, 1
          end,
          set = function(_, r, g, b)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.accentColor = { r = r, g = g, b = b }
          end,
          order = 50,
        },
      },
    },
    notifications = {
      type = "group",
      name = "Notifications",
      order = 2,
      args = {
        header = { type = "header", name = "Notifications", order = 0 },
        desc = { type = "description", name = "Configure when and how you are notified (dev placeholders).", order = 1 },
        enableSound = {
          type = "toggle",
          name = "Enable sound",
          desc = "Play a sound when a notification is shown.",
          get = function() return devGet("enableSound") ~= false end,
          set = function(_, v) devSet("enableSound", v) end,
          order = 10,
        },
        notifyInCombat = {
          type = "toggle",
          name = "Notify in combat",
          desc = "Show notifications even while in combat.",
          get = function() return devGet("notifyInCombat") end,
          set = function(_, v) devSet("notifyInCombat", v) end,
          order = 20,
        },
        notificationDuration = {
          type = "input",
          name = "Duration (seconds)",
          desc = "How long notifications stay on screen.",
          get = function() return tostring(devGet("notificationDuration") or "5") end,
          set = function(_, v) devSet("notificationDuration", v) end,
          order = 30,
        },
        testNotify = {
          type = "execute",
          name = "Test notification",
          func = function() printMsg("Test notification (dev)") end,
          order = 40,
        },
      },
    },
    combat = {
      type = "group",
      name = "Combat",
      order = 3,
      args = {
        header = { type = "header", name = "Combat", order = 0 },
        autoToggleCombatLog = {
          type = "toggle",
          name = "Auto combat log",
          desc = "Placeholder.",
          get = function() return devGet("autoCombatLog") ~= false end,
          set = function(_, v) devSet("autoCombatLog", v) end,
          order = 10,
        },
        showCombatFeedback = {
          type = "toggle",
          name = "Combat feedback",
          desc = "Show on-screen feedback during combat (placeholder).",
          get = function() return devGet("combatFeedback") end,
          set = function(_, v) devSet("combatFeedback", v) end,
          order = 20,
        },
        hideInCombat = {
          type = "toggle",
          name = "Hide UI in combat",
          desc = "Hide certain UI elements when entering combat.",
          get = function() return devGet("hideInCombat") end,
          set = function(_, v) devSet("hideInCombat", v) end,
          order = 30,
        },
      },
    },
    raid = {
      type = "group",
      name = "Raid & Dungeons",
      order = 4,
      args = {
        header = { type = "header", name = "Raid & Dungeons", order = 0 },
        desc = { type = "description", name = "Options for group content (placeholders).", order = 1 },
        showRaidFrames = {
          type = "toggle",
          name = "Show raid frames",
          desc = "Display custom raid frames when in a raid group.",
          get = function() return devGet("showRaidFrames") end,
          set = function(_, v) devSet("showRaidFrames", v) end,
          order = 10,
        },
        announceKeystones = {
          type = "toggle",
          name = "Announce keystones",
          desc = "Announce your mythic+ keystone to party or guild.",
          get = function() return devGet("announceKeystones") end,
          set = function(_, v) devSet("announceKeystones", v) end,
          order = 20,
        },
        dungeonFilter = {
          type = "input",
          name = "Dungeon filter",
          desc = "Filter dungeons by name or ID (placeholder).",
          get = function() return tostring(devGet("dungeonFilter") or "") end,
          set = function(_, v) devSet("dungeonFilter", v) end,
          order = 30,
        },
        resetSettings = {
          type = "execute",
          name = "Reset raid options",
          func = function() printMsg("Raid options reset (dev)") end,
          order = 40,
        },
      },
    },
    interface = {
      type = "group",
      name = "Interface",
      order = 5,
      args = {
        header = { type = "header", name = "Interface", order = 0 },
        tooltipsEnabled = {
          type = "toggle",
          name = "Show tooltips",
          desc = "Enable tooltips for addon elements.",
          get = function() return devGet("tooltips") ~= false end,
          set = function(_, v) devSet("tooltips", v) end,
          order = 10,
        },
        fontSize = {
          type = "input",
          name = "Font size",
          desc = "Base font size for addon text (e.g. 12).",
          get = function() return tostring(devGet("fontSize") or "12") end,
          set = function(_, v) devSet("fontSize", v) end,
          order = 20,
        },
        language = {
          type = "input",
          name = "Language code",
          desc = "Override language (e.g. enUS, deDE). Leave empty for game locale.",
          get = function() return tostring(devGet("language") or "") end,
          set = function(_, v) devSet("language", v) end,
          order = 30,
        },
      },
    },
    debug = {
      type = "group",
      name = "Debug",
      order = 6,
      args = {
        header = { type = "header", name = "Debug", order = 0 },
        desc = { type = "description", name = "Development and debugging options.", order = 1 },
        verboseLogging = {
          type = "toggle",
          name = "Verbose logging",
          desc = "Print extra debug messages to chat.",
          get = function() return devGet("verbose") end,
          set = function(_, v) devSet("verbose", v) end,
          order = 10,
        },
        dumpSettings = {
          type = "execute",
          name = "Dump settings to chat",
          func = function()
            printMsg("LiqUIDB keys: " .. (LiqUIDB and "present" or "nil"))
            if LiqUIDB and LiqUIDB.dev then
              for k, v in pairs(LiqUIDB.dev) do printMsg("  dev." .. tostring(k) .. " = " .. tostring(v)) end
            end
          end,
          order = 20,
        },
        reloadUI = {
          type = "execute",
          name = "Reload UI",
          func = function() ReloadUI() end,
          order = 30,
        },
      },
    },
    testing = {
      type = "group",
      name = "Testing",
      order = 7,
      args = {
        header = { type = "header", name = "Scroll & controls test", order = 0 },
        desc = { type = "description", name = "Many options to test scrollbar and all control types.", order = 1 },
        singleChoice = {
          type = "select",
          name = "Single choice",
          values = { a = "Option A", b = "Option B", c = "Option C" },
          get = function() return devGet("singleChoice") or "a" end,
          set = function(_, v) devSet("singleChoice", v) end,
          order = 5,
        },
        multiChoice = {
          type = "multiselect",
          name = "Multi choice",
          desc = "Pick multiple options.",
          values = { x = "Extra", y = "Yes", z = "Zoom" },
          get = function(_, k) return (devGet("multiChoice") or {})[k] end,
          set = function(_, k, v)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.multiChoice = LiqUIDB.dev.multiChoice or {}
            LiqUIDB.dev.multiChoice[k] = v
          end,
          order = 6,
        },
        testColor = {
          type = "color",
          name = "Test color",
          hasAlpha = true,
          get = function()
            local c = LiqUIDB.dev and LiqUIDB.dev.testColor
            if c then return c.r, c.g, c.b, c.a or 1 end
            return 0.5, 0.5, 0.5, 1
          end,
          set = function(_, r, g, b, a)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.testColor = { r = r, g = g, b = b, a = a or 1 }
          end,
          order = 7,
        },
      },
    },
    scrollTest = {
      type = "group",
      name = "Scroll test",
      order = 8,
      args = {},
    },
  },
}

do
  local scrollArgs = options.args.scrollTest.args
  scrollArgs.header = { type = "header", name = "Many rows for scrollbar", order = 0 }
  for i = 1, 28 do
    local isInput = (i % 4 == 0)
    scrollArgs["row" .. i] = {
      type = isInput and "input" or "toggle",
      name = "Option " .. i,
      order = 10 + i,
    }
    if isInput then
      scrollArgs["row" .. i].get = function() return tostring(devGet("scroll_" .. i) or "") end
      scrollArgs["row" .. i].set = function(_, v) devSet("scroll_" .. i, v) end
    else
      scrollArgs["row" .. i].get = function() return devGet("scroll_" .. i) end
      scrollArgs["row" .. i].set = function(_, v) devSet("scroll_" .. i, v) end
    end
  end
end

LiqUI.Settings:Register("LiqUITesting", options, "LiqUI Testing")

SLASH_LIQUI1 = "/liqui"
SlashCmdList.LIQUI = function() LiqUI.Settings:Toggle() end
