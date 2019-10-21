on prepare(me, tdata)
  if tdata.getAt("SWITCHON") = "ON" then
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

on updateStuffdata(me, tProp, tValue)
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
  if pActive then
    pTimer = pTimer + 1
    if pTimer > 4 then
      tNewNameE = "hcamme_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
      tNewNameG = "hcamme_g_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pActive
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
      tNewNameH = "hcamme_h_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pAnimFrame
      me.getPropRef(#pSprList, 8).castNum = abs(getmemnum(tNewNameH))
      tNewNameF = "hcamme_f_0_1_2_" & me.getProp(#pDirection, 1) & "_" & pAnimFrame
      me.getPropRef(#pSprList, 6).castNum = abs(getmemnum(tNewNameF))
      pTimer = 0
      pChanges = 1
    end if
  else
    tNewNameE = "hcamme_e_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameF = "hcamme_f_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameG = "hcamme_g_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    tNewNameH = "hcamme_h_0_1_2_" & me.getProp(#pDirection, 1) & "_" & 0
    me.getPropRef(#pSprList, 5).castNum = abs(getmemnum(tNewNameE))
    me.getPropRef(#pSprList, 6).castNum = abs(getmemnum(tNewNameF))
    me.getPropRef(#pSprList, 7).castNum = abs(getmemnum(tNewNameG))
    me.getPropRef(#pSprList, 8).castNum = abs(getmemnum(tNewNameH))
    pChanges = 0
  end if
  me.getPropRef(#pSprList, 5).width = member.width
  me.getPropRef(#pSprList, 5).height = member.height
  me.getPropRef(#pSprList, 6).width = member.width
  me.getPropRef(#pSprList, 6).height = member.height
  me.getPropRef(#pSprList, 7).width = member.width
  me.getPropRef(#pSprList, 7).height = member.height
  me.getPropRef(#pSprList, 8).width = member.width
  me.getPropRef(#pSprList, 8).height = member.height
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
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SWITCHON" & "/" & tStr)
  else
    getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY)
  end if
  return(1)
  exit
end