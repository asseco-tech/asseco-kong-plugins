function urldecode(s)
  s = s:gsub('+', ' ')
       :gsub('%%(%x%x)', function(h)
                           return string.char(tonumber(h, 16))
                         end)
  return s
end

function parseurl(s)
  s = s:match('%s*(.+)')
  if not s then return nil end
  local ans = {}
  for k,v in s:gmatch('([^&=?]-)=([^&=?]+)' ) do
    ans[ k ] = urldecode(v)
  end
  return ans
end

function parseurl(s, param)
  s = s:match('%s*(.+)')
  if not s then return nil end
  local ans = nil
  for k,v in s:gmatch('([^&=?]-)=([^&=?]+)' ) do
    if k == param then
      ans = urldecode(v)
      break
    end
  end
  return ans
end
