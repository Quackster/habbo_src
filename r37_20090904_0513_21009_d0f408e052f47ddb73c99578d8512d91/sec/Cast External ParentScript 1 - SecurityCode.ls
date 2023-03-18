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
      return [26417, 7007, 23303, 10522, 1861, 6955, 20261]
    #p:
      return [26929, 10550, 12713, 28003, 16826, 28016, 13112, 31032, 5385, 26895, 3893, 15710, 21876, 29106, 15120, 25898, 7952, 25391, 18877, 3939]
  end case
end

on handler tName
  return 0
end

on handlers
  return []
end
