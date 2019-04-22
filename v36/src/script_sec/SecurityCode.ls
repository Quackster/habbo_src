on getLoginParameter(me, tPassword, tParameter)
  if _player <> void() then
    if _player.traceScript then
      return(0)
    end if
  end if
  _player.traceScript = 0
  _player.traceScript = 0
  if ilk(tParameter) <> #symbol then
    return(0)
  end if
  if tPassword <> "testing" then
    return(0)
  end if
  if me = #g then
    return([1879, 25882, 30078, 19738, 5028, 17707, 4371])
  else
    if me = #p then
      return([28977, 6058, 6561, 17252, 10147, 10014, 4957, 9030, 21314, 266, 7016, 354, 7454, 21282, 12085, 12210, 5444, 14086, 19282, 8045])
    end if
  end if
  exit
end

on handler(tName)
  return(0)
  exit
end

on handlers()
  return([])
  exit
end