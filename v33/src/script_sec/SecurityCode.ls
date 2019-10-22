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
    return([32561, 8998, 950, 29459, 18193, 11607, 5954, 10035, 21438, 11179])
  else
    if (tParameter = #p) then
      return([7428, 22321, 14152, 3853, 6961, 15119, 23348, 18690, 24373, 11593, 22349, 23808, 22451, 15709, 18190, 16198, 29452, 10173, 17854, 12040, 10164, 21926, 23423, 11034, 2334, 6950, 1841, 21795, 25351])
    end if
  end if
end

on handler tName 
  return FALSE
end

on handlers  
  return([])
end
