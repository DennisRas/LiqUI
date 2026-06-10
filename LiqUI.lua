assert(LibStub, "LiqUI requires LibStub")

local MAJOR, MINOR = "LiqUI-1.0", 1
---@class LiqUI
local LiqUI = LibStub:NewLibrary(MAJOR, MINOR)
if not LiqUI then
  return
end

LiqUI.minor = MINOR

_G.LiqUI = LiqUI

---@param instance LiqUI_Instance
---@param prototype table
---@param state table?
---@return table
function LiqUI.BindManager(instance, prototype, state)
  local manager = state or {}
  setmetatable(manager, {
    __index = function(_, key)
      local value = prototype[key]
      if value ~= nil then
        return value
      end
      return instance[key]
    end,
  })
  return manager
end

---@param config LiqUI_NewOptions
---@return LiqUI_Instance
function LiqUI:New(config)
  if not config or not config.name or config.name == "" then
    error("LiqUI:New requires name", 2)
  end
  if type(config.db) ~= "table" then
    error("LiqUI:New requires db", 2)
  end

  local db = config.db
  db.windows = db.windows or {}
  db.tables = db.tables or {}
  db.loggers = db.loggers or {}

  LiqUI.instances = LiqUI.instances or {}
  local existing = LiqUI.instances[config.name]
  if existing then
    existing.db = db
    return existing
  end

  ---@type LiqUI_Instance
  local instance = {
    name = config.name,
    db = db,
  }

  for key, mod in pairs(LiqUI) do
    if type(mod) == "table" and mod.Embed then
      mod:Embed(instance)
    end
  end

  setmetatable(instance, { __index = LiqUI })
  LiqUI.instances[config.name] = instance
  return instance
end
