on getLoginParameter me, tPassword, tParameter 
  if _player <> void() then
    if _player.traceScript then
      return FALSE
    end if
  end if
  _player.traceScript = 0
  _player.traceScript = 0
  if ilk(tParameter) <> #symbol then
    return FALSE
  end if
  if tPassword <> "testing" then
    return FALSE
  end if
  if (tParameter = #g) then
    return([17716, 21350, 6967, 24367, 6933, 31082, 28476, 2489])
  else
    if (tParameter = #p) then
      return([30001, 14120, 26040, 10077, 8504, 379, 29027, 8101, 7476, 8043, 10662, 24398, 3007, 17669, 9126, 6941, 7434, 15733, 19712, 23352])
    end if
  end if
end

on handler tName 
  return FALSE
end

on handlers  
  return([])
end
