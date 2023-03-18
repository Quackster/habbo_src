property ancestor, myswitchON
global gpObjects, gChosenStuffId, gChosenStuffSprite

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  return me
end

on exitFrame me
  mname = me.lSprites[2].member.name
  if myswitchON then
    newMName = char 1 to mname.length - 1 of mname & 0
    me.lSprites[2].locZ = me.lSprites[1].locZ + 2
    if getmemnum(newMName) > 0 then
      me.lSprites[2].castNum = getmemnum(newMName)
    end if
  else
    if myswitchON = 0 then
      newMName = char 1 to mname.length - 1 of mname & 1
      me.lSprites[2].locZ = me.lSprites[1].locZ + 1000
      if getmemnum(newMName) > 0 then
        me.lSprites[2].castNum = getmemnum(newMName)
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
