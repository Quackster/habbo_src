on getLoginParameter me, tPassWord, tParameter
  if _player <> VOID then
    if _player.traceScript then
      return 0
    end if
  end if
  _player.traceScript = 0
  _movie.traceScript = 0
  if ilk(tParameter) <> #symbol then
    return 0
  end if
  if tPassWord <> "testing" then
    return 0
  end if
  case tParameter of
    #g:
      return [32560, 17717]
    #p:
      return [27441, 9509, 3370, 24892, 15116, 19770, 30133, 16670, 2363, 20781, 23920, 15657, 25886, 20256, 6471, 27501, 30552, 29553, 25366, 18194]
  end case
end

on handler tName
  return 0
end

on handlers
  return []
end
