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
      return [24881, 10513, 27925, 29456, 13592, 22370, 3846, 9038]
    #p:
      return [28977, 9531, 21854, 19264, 22436, 8564, 31568, 20303, 26995, 855, 26388, 26039, 12159, 18259, 1955, 3842, 5900, 22809, 1281, 21270]
  end case
end

on handler tName
  return 0
end

on handlers
  return []
end
