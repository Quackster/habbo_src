property pIgnoreList

on getIgnoreStatus me, tUserName
  if voidp(pIgnoreList) then
    me.reset()
  end if
  if pIgnoreList = [] then
    return 0
  end if
  return pIgnoreList.findPos(tUserName)
end

on setIgnoreStatus me, tUserName, tStatus
  if voidp(pIgnoreList) then
    me.reset()
  end if
  if tStatus then
    if not pIgnoreList.findPos(tUserName) then
      pIgnoreList.add(tUserName)
    end if
  else
    pIgnoreList.deleteOne(tUserName)
  end if
  return 1
end

on reset me
  pIgnoreList = []
  return 1
end
