property polyfonfprand, fireplaceOn, ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  polyfonfprand = 0
  if (getaProp(me.pData, "FIREON") = "ON") then
    setOn(me)
  else
    setOff(me)
  end if
  return(me)
end

on updateStuffdata me, tProp, tValue 
  put(tValue)
  if (tValue = "ON") then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me 
  polyfonfprand = (polyfonfprand + 1)
  if (fireplaceOn = 0) then
    newMName = "fireplace_polyfon_c_0_2_1_4_99"
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName)
    end if
  end if
  if (count(me.lSprites) = 3) and fireplaceOn and polyfonfprand > 2 then
    polyfonfprand = 0
    mname = me.getPropRef(#lSprites, 3).member.name
    newMName = mname.char[1..(mname.length - 1)] & (random(11) - 1)
    ranni = random(10)
    if (newMName = "fireplace_polyfon_c_0_2_1_4_7") and ranni < 9 then
      newMName = "fireplace_polyfon_c_0_2_1_4_5"
    end if
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName)
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
    if (fireplaceOn = 1) then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "FIREON" & "/" & onString)
  end if
end
