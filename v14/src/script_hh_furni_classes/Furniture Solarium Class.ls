property pToggleParts, pState

on prepare me, tdata 
  pToggleParts = ["0":[[#sprite:"c", #member:void()]], "1":[[#sprite:"c", #member:"0"]]]
  me.setState(tdata.getAt(#stuffdata))
  return TRUE
end

on updateStuffdata me, tValue 
  me.setState(tValue)
end

on setState me, tValue 
  if not listp(pToggleParts) then
    return FALSE
  end if
  if (tValue = void()) then
    tValue = pToggleParts.getPropAt(1)
  end if
  tPartStates = pToggleParts.getAt(tValue)
  if not listp(tPartStates) then
    tPartStates = pToggleParts.getAt(1)
    tValue = pToggleParts.getPropAt(1)
  end if
  pState = tValue
  repeat while tPartStates <= 1
    tPart = getAt(1, count(tPartStates))
    tPartId = tPart.sprite
    tmember = tPart.member
    if tmember <> void() then
      me.switchMember(tPartId, tmember)
    end if
    me.setPartVisible(tPartId, tmember <> void())
  end repeat
  return TRUE
end

on select me 
  if the doubleClick then
    if (pState = "1") then
      pState = "0"
    else
      pState = "1"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:pState])
  end if
  return TRUE
end

on switchMember me, tPart, tNewMem 
  tSprNum = (charToNum(tPart) - (charToNum("a") - 1))
  if me.count(#pSprList) < tSprNum or tSprNum <= 0 then
    return FALSE
  end if
  tName = me.getPropRef(#pSprList, tSprNum).member.name
  tName = tName.getProp(#char, 1, (tName.length - 1)) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  return TRUE
end

on setPartVisible me, tPart, tstate 
  tSprNum = (charToNum(tPart) - (charToNum("a") - 1))
  if me.count(#pSprList) < tSprNum or tSprNum <= 0 then
    return FALSE
  end if
  me.getPropRef(#pSprList, tSprNum).visible = tstate
  return TRUE
end
