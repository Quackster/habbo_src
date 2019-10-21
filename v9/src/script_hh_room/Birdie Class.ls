property pLastUpdate, pState, pFrame

on deconstruct me 
  repeat while me.pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  me.pSprList = []
  pState = 3
  return TRUE
end

on prepare me, tdata 
  if (tdata.getAt(#stuffdata) = "ON") then
    me.setOn()
  end if
  pFrame = 0
  pLastUpdate = the milliSeconds
  return TRUE
end

on updateStuffdata me, tValue 
  pFrame = 0
  pLastUpdate = the milliSeconds
  if (tValue = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if the milliSeconds < pLastUpdate then
    return()
  end if
  if me.count(#pSprList) < 1 then
    return()
  end if
  if (pState = 1) then
    tAnim = [0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3, 2, 3, 2, 3, 3, 1, 0]
    pFrame = (pFrame + 1)
    if pFrame > tAnim.count then
      pFrame = 1
    end if
    tName = me.getPropRef(#pSprList, 2).member.name
    if tName <> "" then
      tmember = member(getmemnum(tName.getProp(#char, 1, (length(tName) - 1)) & tAnim.getAt(pFrame)))
      me.getPropRef(#pSprList, 2).castNum = tmember.number
      me.getPropRef(#pSprList, 2).width = tmember.width
      me.getPropRef(#pSprList, 2).height = tmember.height
      if (pFrame = tAnim.count) then
        pLastUpdate = (the milliSeconds + 4000)
      else
        pLastUpdate = (the milliSeconds + 100)
      end if
    end if
  else
    if (pState = 2) then
      pState = 3
      pFrame = 0
      tName = me.getPropRef(#pSprList, 2).member.name
      if tName <> "" then
        tmember = member(getmemnum(tName.getProp(#char, 1, (length(tName) - 1)) & pFrame))
        me.getPropRef(#pSprList, 2).castNum = tmember.number
        me.getPropRef(#pSprList, 2).width = tmember.width
        me.getPropRef(#pSprList, 2).height = tmember.height
      end if
    end if
  end if
end

on setOn me 
  pState = 1
end

on setOff me 
  pState = 2
end

on select me 
  if the doubleClick then
    if (pState = 1) then
      tOnString = "OFF"
    else
      tOnString = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tOnString])
  end if
end
