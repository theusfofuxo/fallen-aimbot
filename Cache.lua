-- Utils/Cache.lua
-- Cache simples para dados com tempo de vida
local Cache = {}

function Cache.new(ttl)
    return {
        _data = {},
        _ttl = ttl or 0.1,
        _lastClean = os.clock()
    }
end

function Cache:get(key)
    local entry = self._data[key]
    if not entry then return nil end
    if os.clock() - entry.time > self._ttl then
        self._data[key] = nil
        return nil
    end
    return entry.value
end

function Cache:set(key, value)
    self._data[key] = { value = value, time = os.clock() }
end

function Cache:clear()
    self._data = {}
end

return Cache
