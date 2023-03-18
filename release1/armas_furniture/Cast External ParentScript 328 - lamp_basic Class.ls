property ancestor, myswitchON
global gpObjects, gChosenStuffId, gChosenStuffSprite

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  if getaProp(me.pData, "SWITCHON") = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
  return me
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me
  mname = me.lSprites[2].member.name
  mName2 = me.lSprites[3].member.name
  if myswitchON then
    newMName = char 1 to mname.length - 1 of mname & 0
    newMName2 = char 1 to mName2.length - 1 of mName2 & 0
    me.lSprites[2].locZ = me.lSprites[1].locZ + 2
    me.lSprites[3].locZ = me.lSprites[2].locZ + 2
    if getmemnum(newMName) > 0 then
      me.lSprites[2].castNum = getmemnum(newMName)
      me.lSprites[3].castNum = getmemnum(newMName2)
    end if
  else
    if myswitchON = 0 then
      newMName = char 1 to mname.length - 1 of mname & 1
      newMName2 = char 1 to mName2.length - 1 of mName2 & 1
      me.lSprites[2].locZ = me.lSprites[1].locZ + 1
      me.lSprites[3].locZ = me.lSprites[2].locZ + 1
      if getmemnum(newMName) > 0 then
        me.lSprites[2].castNum = getmemnum(newMName)
        me.lSprites[3].castNum = getmemnum(newMName2)
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
