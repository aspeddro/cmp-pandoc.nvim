local Tbl = {}

function Tbl:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tbl:__concat(list)
  local res = Tbl.clone(self)
  Tbl.extend(res, list)
  return res
end

function Tbl:clone()
  local lst = setmetatable({}, getmetatable(self))
  Tbl.extend(lst, self)
  return lst
end

function Tbl:extend(list)
  for i = 1, #list do
    self[#self + 1] = list[i]
  end
end

function Tbl:join(sep)
  return table.concat(self, sep or "\n")
end

function Tbl:is_empty()
  return #self == 0 and true or false
end

function Tbl:insert(list)
  table.insert(self, list)
end

function Tbl:map(fn)
  local res = setmetatable({}, getmetatable(self))
  for i = 1, #self do
    res[i] = fn(self[i], i)
  end
  return res
end

function Tbl:filter(pred)
  local res = setmetatable({}, getmetatable(self))
  for i = 1, #self do
    if pred(self[i], i) then
      res[#res + 1] = self[i]
    end
  end
  return res
end

return Tbl
