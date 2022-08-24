on getLoginParameter me, tPassWord, tParameter
  if (_player <> VOID) then
    if _player.traceScript then
      return 0
    end if
  end if
  _player.traceScript = 0
  _movie.traceScript = 0
  if (ilk(tParameter) <> #symbol) then
    return 0
  end if
  if (tPassWord <> "testing") then
    return 0
  end if
  case tParameter of
    #g:
      return [17201, 25433, 16757, 18753, 6581, 20405, 22897, 26947]
    #p:
      return [14613, 3915, 11064, 10568, 10591, 29566, 28070, 13112, 18207, 26958, 28957, 32685, 21847, 16745, 8025, 26953, 8635, 8056, 24872, 17688, 25451, 15717, 15199, 11532, 20815, 1337, 1351, 2347, 24427]
  end case
end

on handler tName
  return 0
end

on handlers
  return []
end
