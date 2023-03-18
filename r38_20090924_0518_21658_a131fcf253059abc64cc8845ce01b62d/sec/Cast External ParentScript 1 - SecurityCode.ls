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
      return [17716, 21350, 6967, 24367, 6933, 31082, 28476, 2489]
    #p:
      return [30001, 14120, 26040, 10077, 8504, 379, 29027, 8101, 7476, 8043, 10662, 24398, 3007, 17669, 9126, 6941, 7434, 15733, 19712, 23352]
  end case
end

on handler tName
  return 0
end

on handlers
  return []
end
