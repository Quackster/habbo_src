property ancestor, fireplaceOn, polyfonfprand
global gpObjects, gChosenStuffId, gChosenStuffSprite

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  polyfonfprand = 0
  if getaProp(me.pData, "FIREON") = "ON" then
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
  polyfonfprand = polyfonfprand + 2
  if fireplaceOn and (polyfonfprand > 90) then
    polyfonfprand = 0
    mname = me.lSprites[2].member.name
    newMName = char 1 to mname.length - 1 of mname & random(8) - 1
    ranni = random(10)
    if (newMName = "red_tv_b_0_1_1_2_7") and (ranni < 9) then
      newMName = "red_tv_b_0_1_1_2_5"
    else
      if newMName = "red_tv_b_0_1_1_2_7" then
        polyfonfprand = 55
      end if
    end if
    if getmemnum(newMName) > 0 then
      me.lSprites[2].castNum = getmemnum(newMName)
    end if
  end if
  if fireplaceOn = 0 then
    newMName = "red_tv_b_0_1_1_2_9"
    if getmemnum(newMName) > 0 then
      me.lSprites[2].castNum = getmemnum(newMName)
    end if
  end if
end

on setOn me
  fireplaceOn = 1
end

on setOff me
  fireplaceOn = 0
end

on mouseDown me
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if fireplaceOn = 1 then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "FIREON" & "/" & onString)
  end if
end
