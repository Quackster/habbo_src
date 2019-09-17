property pAnimNow, myswitchON, pFlameFrame, ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  pFlameFrame = 1
  pAnimNow = 0
  if getaProp(me.pData, "SWITCHON") = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
  return(me)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me 
  pAnimNow = pAnimNow + 1
  mname = me.getPropRef(#lSprites, 2).member.name
  mName2 = me.getPropRef(#lSprites, 3).member.name
  if myswitchON then
    newMName = mname.char[1..mname.length - 1] & 0
    newMName2 = mName2.char[1..mName2.length - 1] & 0
    me.getPropRef(#lSprites, 2).locZ = me.getPropRef(#lSprites, 1).locZ + 2
    me.getPropRef(#lSprites, 3).locZ = me.getPropRef(#lSprites, 2).locZ + 2
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 2).castNum = getmemnum(newMName)
      me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName2)
    end if
  else
    if myswitchON = 0 then
      pFlameFrame = pFlameFrame + 1
      if pFlameFrame >= 5 then
        pFlameFrame = 1
      end if
      if pAnimNow mod 9 = 0 then
        newMName = mname.char[1..mname.length - 1] & pFlameFrame
        newMName2 = mName2.char[1..mName2.length - 1] & 1
        me.getPropRef(#lSprites, 2).locZ = me.getPropRef(#lSprites, 1).locZ + 1
        me.getPropRef(#lSprites, 3).locZ = me.getPropRef(#lSprites, 2).locZ + 1
        if getmemnum(newMName) > 0 then
          me.getPropRef(#lSprites, 2).castNum = getmemnum(newMName)
          me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName2)
        end if
      end if
    end if
  end if
end

on setOn me 
  myswitchON = 1
end

on setOff me 
  myswitchON = 0
end

on mouseDown me 
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if myswitchON = 1 then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "SWITCHON" & "/" & onString)
  end if
end
