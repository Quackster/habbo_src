property pChanges, pActive

on prepare me, tdata 
  if (tdata.getAt("STATUS") = "O") then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (tValue = "O") then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 4 then
    return()
  end if
  tCurName = me.getPropRef(#pSprList, 1).member.name
  tNewName = tCurName.getProp(#char, 1, (length(tCurName) - 11))
  tParts = ["a", "b", "c", "d"]
  i = 1
  repeat while i <= 4
    tMemNum = getmemnum(tNewName & tParts.getAt(i) & "_" & "0_1_1_0_" & pActive)
    if tMemNum > 0 then
      tmember = member(tMemNum)
      me.getPropRef(#pSprList, i).castNum = tMemNum
      me.getPropRef(#pSprList, i).width = tmember.width
      me.getPropRef(#pSprList, i).height = tmember.height
    end if
    i = (1 + i)
  end repeat
  pChanges = 0
end

on setOn me 
  pActive = 1
end

on setOff me 
  pActive = 0
end

on select me 
  if the doubleClick then
    if pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "STATUS" & "/" & tStr)
  end if
  return TRUE
end
