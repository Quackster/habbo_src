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
    return([32560, 17717])
  else
    if me = #p then
      return([27441, 9509, 3370, 24892, 15116, 19770, 30133, 16670, 2363, 20781, 23920, 15657, 25886, 20256, 6471, 27501, 30552, 29553, 25366, 18194])
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