--- @deprecated
local M = {}

--- @deprecated
function M.set_of(list)
  local set = {}
  for i = 1, #list do
    set[list[i]] = true
  end
  return set
end

--- @deprecated
function M.not_in(var, arr)
  if M.set_of(arr)[var] == nil then
    return true
  end
end

return M
