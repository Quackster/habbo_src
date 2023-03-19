property pChanges, pActive

on prepare me, tdata
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
    pChanges = 1
  end if
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 2 then
    return 
  end if
  tCurName = me.pSprList[2].member.name
  tNewName = tCurName.char[1..length(tCurName) - 1] & pActive
  tMemNum = getmemnum(tNewName)
  if pActive then
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tItemCount = tNewName.item.count
    if (tNewName.item[tItemCount - 1] = "0") or (tNewName.item[tItemCount - 1] = "6") then
      me.pSprList[2].locZ = me.pSprList[1].locZ + 502
    else
      if (tNewName.item[tItemCount - 1] <> "0") and (tNewName.item[tItemCount - 1] <> "6") then
        me.pSprList[2].locZ = me.pSprList[1].locZ + 2
      end if
    end if
    the itemDelimiter = tDelim
  else
    me.pSprList[2].locZ = me.pSprList[1].locZ + 1
  end if
  if tMemNum > 0 then
    tmember = member(tMemNum)
    me.pSprList[2].castNum = tMemNum
    me.pSprList[2].width = tmember.width
    me.pSprList[2].height = tmember.height
  end if
  pChanges = 0
end

on setOn me
  pActive = 1
  if me.pLoczList.count < 2 then
    return 0
  end if
  me.pLoczList[2] = [200, 200, 0, 0, 0, 0, 200, 200]
end

on setOff me
  pActive = 0
  if me.pLoczList.count < 2 then
    return 0
  end if
  me.pLoczList[2] = [0, 0, 0, 0, 0, 0, 0, 0]
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY])
  end if
  return 1
end
