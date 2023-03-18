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
  mname = me.lSprites[5].member.name
  mName2 = me.lSprites[6].member.name
  mName3 = me.lSprites[7].member.name
  mName4 = me.lSprites[8].member.name
  if myswitchON then
    newMName = char 1 to mname.length - 1 of mname & 0
    newMName2 = char 1 to mName2.length - 1 of mName2 & 0
    newMName3 = char 1 to mName3.length - 1 of mName3 & 0
    newMName4 = char 1 to mName4.length - 1 of mName4 & 0
    if getmemnum(newMName) > 0 then
      me.lSprites[5].castNum = getmemnum(newMName)
      me.lSprites[6].castNum = getmemnum(newMName2)
      me.lSprites[7].castNum = getmemnum(newMName3)
      me.lSprites[8].castNum = getmemnum(newMName4)
    end if
  else
    if myswitchON = 0 then
      newMName = char 1 to mname.length - 1 of mname & 1
      newMName2 = char 1 to mName2.length - 1 of mName2 & 1
      newMName3 = char 1 to mName3.length - 1 of mName3 & 1
      newMName4 = char 1 to mName4.length - 1 of mName4 & 1
      if getmemnum(newMName) > 0 then
        me.lSprites[5].castNum = getmemnum(newMName)
        me.lSprites[6].castNum = getmemnum(newMName2)
        me.lSprites[7].castNum = getmemnum(newMName3)
        me.lSprites[8].castNum = getmemnum(newMName4)
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
