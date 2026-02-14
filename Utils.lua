local Utils = LiqUI.Utils

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
