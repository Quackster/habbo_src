on prepare(me, tdata)
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  pTimer = 0
  pAnimFrame = 1
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
  exit
end

on update(me)
  if me.count(#pSprList) < 8 then
    return()
  end if
  if not pChanges then
    return()
  end if
  tName = undefined.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tClass = tName.getProp(#item, 1, tName.count(#item) - 6)
  the itemDelimiter = tDelim
  if pActive then
    pTimer = pTimer + 1
    if pTimer > 4 then
      tNewNameE = tClass & "_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
      tNewNameG = tClass & "_g_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
      if memberExists(tNewNameE) then
        me.getPropRef(#pSprList, 5).castNum = abs(getmemnum(tNewNameE))
      end if
      if memberExists(tNewNameG) then
        me.getPropRef(#pSprList, 7).castNum = abs(getmemnum(tNewNameG))
      end if
      pAnimFrame = pAnimFrame + 1
      if pAnimFrame > 3 then
        pAnimFrame = 1
      end if
      tNewNameH = tClass & "_h_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pAnimFrame
      me.getPropRef(#pSprList, 8).castNum = abs(getmemnum(tNewNameH))
      tNewNameF = tClass & "_f_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pAnimFrame
      me.getPropRef(#pSprList, 6).castNum = abs(getmemnum(tNewNameF))
      pTimer = 0
      pChanges = 1
    end if
  else
    tNewNameE = tClass & "_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameF = tClass & "_f_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameG = tClass & "_g_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameH = tClass & "_h_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    me.getPropRef(#pSprList, 5).castNum = abs(getmemnum(tNewNameE))
    me.getPropRef(#pSprList, 6).castNum = abs(getmemnum(tNewNameF))
    me.getPropRef(#pSprList, 7).castNum = abs(getmemnum(tNewNameG))
    me.getPropRef(#pSprList, 8).castNum = abs(getmemnum(tNewNameH))
    pChanges = 0
  end if
  me.getPropRef(#pSprList, 5).width = undefined.width
  me.getPropRef(#pSprList, 5).height = undefined.height
  me.getPropRef(#pSprList, 6).width = undefined.width
  me.getPropRef(#pSprList, 6).height = undefined.height
  me.getPropRef(#pSprList, 7).width = undefined.width
  me.getPropRef(#pSprList, 7).height = undefined.height
  me.getPropRef(#pSprList, 8).width = undefined.width
  me.getPropRef(#pSprList, 8).height = undefined.height
  exit
end

on setOn(me)
  pActive = 1
  exit
end

on setOff(me)
  pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY])
  end if
  return(1)
  exit
end